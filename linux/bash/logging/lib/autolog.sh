CURRENT_LOG=$LOG_ROOT/current

init_log() {
    if [ ! -e "$LOG_ROOT" ]; then
        mkdir -p "$LOG_ROOT"
    fi

    if  [ ! -e "$CURRENT_LOG" ] || [ -e "$CURRENT_LOG/.finished" ]; then
        local log_dir=$LOG_ROOT/$(date +%Y%m%d-%H%M%S)
        mkdir "$log_dir"
        rm -f "$CURRENT_LOG"
        ln -s "$(realpath "$log_dir")" "$CURRENT_LOG"
    fi
    LOG_DIR=$(readlink "$CURRENT_LOG")
}

finalize_current_log() {
    touch "$CURRENT_LOG/.finished"
}

start_autolog() {
    local log_file=$CURRENT_LOG/$(basename "$0").log

    coproc logproc_writer {
        cat > "$log_file"
    }
    local log_writer_fd=${logproc_writer[1]}

    logproc_stdout() {
        set +x
        while IFS= read -r line; do
            echo "$line" >&$log_writer_fd
            echo "$line" >&3
        done
    }

    logproc_stderr() {
        set +x
        while IFS= read -r line || [ -n "$line" ]; do
            echo "stderr: $line" >&$log_writer_fd
            if [ -t 4 ]; then
                term_color $TERM_AF_RED
                echo "$line"
                term_clear
            else
                echo "stderr: $line"
            fi >&4
        done
    }

    exec 3>&1 4>&2 > >(logproc_stdout) 2> >(logproc_stderr)
}

if bool "$ENABLE_AUTOLOG"; then
    init_log
    start_autolog
fi
