set -x

mkln() {
	local from=$1; shift
	local to=$1; shift
	ip link add name $from-$to type veth peer name $to-$from
}

mkbr() {
	local name=$1; shift
	ip netns add $name
	ip netns exec $name /bin/bash <<-SCRIPT
		set -x
		ip link add $name type bridge
		ip link set dev $name up
	SCRIPT
	for n in "$@"; do
		local link_name=$name-$n
		mkln $name $n
		ip link set dev $link_name netns $name
		ip netns exec $name /bin/bash <<-SCRIPT
			ip link set dev $link_name promisc on up
			ip link set dev $link_name master $name
		SCRIPT
	done
}

setup_link() {
	local link_name=$1; shift
	local addr=$1; shift
	local ns=$1; shift

	ip link set dev $link_name netns $ns
	ip netns exec $ns /bin/bash <<-SCRIPT
		ip link set up dev $link_name
		ip addr add $addr dev $link_name
	SCRIPT
}

mkrt() {
	name=$1   ; shift
	ul=$1     ; shift
	ul_addr=$1; shift
	dl=$1     ; shift
	dl_addr=$1; shift

	ip netns add $name
	setup_link $name-$ul $ul_addr $name
	setup_link $name-$dl $dl_addr $name
	ip netns exec $name /bin/bash <<-SCRIPT
		ip link set dev lo up
		sysctl -w net.ipv4.ip_forward=1
	SCRIPT
}

mkhost() {
	name=$1   ; shift
	ul=$1     ; shift
	ul_addr=$1; shift
	gw=$1     ; shift

	ip netns add $name
	setup_link $name-$ul $ul_addr $name
	ip netns exec $name /bin/bash <<-SCRIPT
		ip link set dev lo up
		if [ -n "$gw" ]; then
			ip route add default via $gw
		fi
	SCRIPT
}

mklb() {
	mkrt "$@"
	name=$1   ; shift; shift 4

	target=$1 ; shift
	while :; do
		[ $# -gt 0 ] || break
		nh="$nh nexthop via $1 weight 100"; shift
	done

	ip netns exec $name /bin/bash <<-SCRIPT
		set -x
		ip link set dev lo up
		sysctl -w net.ipv4.ip_forward=1
		sysctl -w net.ipv4.fib_multipath_hash_policy=1

		ip route add $target $nh
	SCRIPT
}

mknscmd() {
	local host=$1; shift
	eval "function $host { ip netns exec $host \"\$@\"; }"
}

mkbr s2 r1 r2 h1
mkhost h1 s2 10.2.0.1/24 127.0.0.1

mkln h0 lb1
mkhost h0 lb1 10.0.0.1/24 10.0.0.2

mkbr s1 lb1 r1 r2
mklb lb1 h0 10.0.0.2/24 s1 10.1.0.1/24 10.2.0.0/24 10.1.0.2 10.1.0.3

mkrt r1 s1 10.1.0.2/24 s2 10.2.0.2/24
mkrt r2 s1 10.1.0.3/24 s2 10.2.0.3/24


ip netns exec r1 ip link set dev r1-s2 address 00:00:00:00:00:01
ip netns exec r2 ip link set dev r2-s2 address 00:00:00:00:00:02
ip netns exec h1 /bin/bash <<-SCRIPT
	iptables -t mangle -A INPUT -m mac --mac-source 00:00:00:00:00:01 -j CONNMARK --set-mark 1
	iptables -t mangle -A INPUT -m mac --mac-source 00:00:00:00:00:02 -j CONNMARK --set-mark 2
	iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark
	iptables -t mangle -A OUTPUT -m mark --mark 1 -j ACCEPT
	iptables -t mangle -A OUTPUT -m mark --mark 2 -j ACCEPT

	ip rule add fwmark 1 table 1
	ip rule add fwmark 2 table 2
	ip route add default table 1 via 10.2.0.2
	ip route add default table 2 via 10.2.0.3
SCRIPT

for h in h0 h1 lb1 r1 r2 s1 s2; do mknscmd $h; done

ip netns exec s1 bridge -c link

bash

ip netns del h0
ip netns del h1

ip netns del r1
ip netns del r2

ip netns del lb1

#ip link set dev s1 down
#ip link delete s1
ip netns del s1
ip netns del s2
