bool() {
    case ${1,,} in
        yes|y|true|t|on|1) return 0 ;;
        no|n|false|f|off|0) return 1 ;;
    esac
    return 2
}
