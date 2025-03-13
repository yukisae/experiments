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
        exec cat > "$log_file"
    }
    local log_writer_fd=${logproc_writer[1]}

    logproc_stdout() {
        set +x
        exec tee -a /dev/fd/${AUTOLOG_STDOUT} >&$log_writer_fd
    }

    logproc_stderr() {
        set +x
        local color_code="$(term_color $TERM_AF_RED)"
        local color_clear="$(term_clear)"
        local writer_fd
        exec {writer_fd}>&$log_writer_fd
        if [ -t ${AUTOLOG_STDOUT} ]; then
            exec tee -a >(exec sed -ue "s@^@stderr: @" >&${writer_fd}) | \
                    sed -uE "s@^(.+)\$@$color_code\\1$color_clear@" >&${AUTOLOG_STDERR}
        else
            exec tee -a >(exec sed -ue "s@^@stderr: @" >&${writer_fd}) | \
                    sed -ue "s@^@stderr: @" >&${AUTOLOG_STDERR}
        fi
    }

    exec {AUTOLOG_STDOUT}>&1 {AUTOLOG_STDERR}>&2 > >(logproc_stdout) 2> >(logproc_stderr)

    # trap EXIT to pass the context to the loggers
    trap 'sleep 0' EXIT
}

if bool "$ENABLE_AUTOLOG"; then
    init_log
    start_autolog
fi
