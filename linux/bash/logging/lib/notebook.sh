example_line() {
    term_color $TERM_AF_CYAN
    echo -n "Example: $@"
    term_clear
    echo
}

example_lines() {
    local line
    term_color $TERM_AF_CYAN
    echo Example:
    sed -e 's@^@  @'
    term_clear
}

example() {
    if [ $# -gt 0 ]; then
        example_line "$@"
    else
        example_lines
    fi
}

notice() {
    term_color $TERM_AF_YELLOW
    echo -n "$@"
    term_clear
    echo
}

decorate() {
    notice "[ $@ ]"
}
