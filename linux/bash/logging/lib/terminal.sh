TERM_AF_RED=1
TERM_AF_GREEN=2
TERM_AF_YELLOW=3
TERM_AF_BLUE=4
TERM_AF_MAGENTA=5
TERM_AF_CYAN=6

is_tty() {
    # exit with 0 if stdout is a TTY
    [ -t 1 ]
}

term_color() {
    local attr=$1; shift
    if is_tty || bool "$COLOR_ALWAYS"; then
        tput setaf $attr
    fi
}

term_clear() {
    if is_tty || bool "$COLOR_ALWAYS"; then
        tput sgr0
        # or echo -n -e '\x1b[0m'
    fi
}
