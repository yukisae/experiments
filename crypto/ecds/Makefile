LDFLAGS := $(shell pkg-config --libs openssl)

.PHONY: all clean

all: ecdsa ecdsa-bin ed25519 ed25519-bin

ecdsa: ecdsa.cxx
	g++ $(LDFLAGS) -o $@ $<

ecdsa-bin: ecdsa.cxx
	# $ ./ecdsa-bin | openssl asn1parse -inform der
	# Sign Buffer Length: 72
	# Sign Length: 71
	# verify: ok
	#     0:d=0  hl=2 l=  69 cons: SEQUENCE
	#     2:d=1  hl=2 l=  33 prim: INTEGER           :B58071C90DB3615C915C143C1D27E6DA704E51CAF75B539097B39B53E06F52F0
	#    37:d=1  hl=2 l=  32 prim: INTEGER           :6BC3AE2A58B37E64E1D5F960C3C8ED7B4A10B4A7FAC394D5DF5F400D96324963
	g++ $(LDFLAGS) -o $@ -DBIN $<

ed25519: ed25519.cxx
	g++ $(LDFLAGS) -o $@ $<

ed25519-bin: ed25519.cxx
	# $ ./ed25519-bin | od -Ax -tx1z -v
	# Sign Buffer Length: 64
	# Sign Length: 64
	# 000000 59 87 9e 1d 86 7d d6 a9 8d 4d 39 ee ad 95 25 a3  >Y....}...M9...%.<
	# 000010 14 10 15 77 06 71 da 3c 9f 0e e0 df 23 5c 1e 49  >...w.q.<....#\.I<
	# 000020 4e 91 29 2d 93 2b 5e 0c 6e c2 92 d9 89 8b 54 5c  >N.)-.+^.n.....T\<
	# 000030 92 48 e7 69 07 31 e3 20 47 01 6d ed 1a 54 ee 06  >.H.i.1. G.m..T..<
	# 000040
	g++ $(LDFLAGS) -o $@ -DBIN $<

clean:
	rm -f ed25519 ed25519-bin ecdsa ecdsa-bin
