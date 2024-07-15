function debugprint -S \
-d 'echo args to stderr if -v=var is true.'

    # temporarily remove nonopt-args
    if contains -i -- -- $argv
        set -e $argv[$i]
        set more_args $argv[$i..-1]
    end

    # should arg-values be passed directly or via env-vars?
    argparse --name="debugprint" \
        --ignore-unknown \
        'e/env-controlled' \
        'h/help' \
        -- $argv

    # actual argument parsing
    not set -q _flag_env_controlled
    and argparse \
        --name="debugprint" \
        -x 'p,P' \
        -x 'n,N' \
        'v/enable-with=' \
        'a=' \
        'p=' \
        'P=' \
        'n' \
        'N' \
        'S/no-space' \
         -- $argv
    or argparse \
        --name="debugprint" \
        -x 'p,P' \
        -x 'n,N' \
        'v/enable-with=' \
        'a' \
        'p' \
        'P' \
        'n' \
        'N' \
        'S/no-space' \
         -- $argv
    # get the values from the options' variables
    and begin
        if set -q DEBUG_PREFIX
            set _flag_p "$DEBUG_PREFIX"
        end
        if set -q DEBUG_PREFIX_COLON
            set _flag_P "$DEBUG_PREFIX_COLON"
        end
        if set -q DEBUG_APPEND
            set _flag_a "$DEBUG_APPEND"
        end
    end
    # put previously removed nonopt-args back
    set -a argv $more_args
    # --enable-with default
    if not set -q _flag_enable_with
        set _flag_enable_with DEBUG
    end
    if not set -q $_flag_enable_with
        set $_flag_enable_with false
    end

    # print help and return 0
    if set -q _flag_help
        echo "echo args to stderr if -v=var is true.

    Usage:
    debugprint [Options] [--] [debug-msg]
    debugprint [debug-msg part 1] [Options] [--] [debug-msg more parts]

    Options:
    '--'
            only nonopt-arguments after this
    'h/help'
            display this help
    'v/enable-with='
            debugprint only executes if
            the specified variable is set to true
            (defaults to DEBUG)
    'e/external-values'
            options (excapt -v) that take a value
            become boolean-options that read an external
            variable as their value
    'a=' DEBUG_APPEND
            append this to debug-msg
    'p=' DEBUG_PREFIX
            prepend this + space to debug-msg
    'P=' DEBUG_PREFIX_COLON
            prepend this + ':' + space to debug-msg
    'n'
            append this + space to prefix
    'N'
            append this + ':' + space to prefix
    'S/no-space'
            do not append space
            affects -{p,P,n,N}; does not affect -a

    Examples:

    ## just a debug-msg
    # debug-msg  # debugprint debug-msg

    ## just the name of the calling function
    # myfunc  # debugprint -n

    ## -p specifies a prefix
    ## -n adds function name after prefix
    # prefix debug-msg  # debugprint -p=prefix debug-msg
    # myfunc debug-msg  # debugprint -n debug-msg
    # prefix myfunc debug-msg  # debugprint -p=prefix -n debug-msg

    ## -P and -N do the same but end on ':'
    # prefix: debug-msg  # debugprint -P=prefix debug-msg
    # myfunc: debug-msg  # debugprint -N debug-msg
    # prefix: myfunc: debug-msg  # debugprint -P=prefix -N debug-msg
    # prefix myfunc: debug-msg  # debugprint -p=prefix -N debug-msg

    ## -S does not add a space to -{p,P,n,N}
    # prefix:debug-msg  # debugprint -S -P=prefix debug-msg
    # myfunc:debug-msg  # debugprint -S -N debug-msg
    # prefix myfunc:debug-msg  # debugprint -S -p='prefix ' -N debug-msg

    ## append a string with -a
    # prefix debug-msg!  # debugprint -p=prefix -a='!' debug-msg
    # prefix myfunc:debug-msg!  # debugprint -S -p='prefix ' -N -a='!' debug-msg
    "
        return 0
    end

    set out

    # Shall we run?
    if test -n "$$_flag_enable_with"
    and test "$$_flag_enable_with" != "false"
    and test "$$_flag_enable_with" != "False"

        # prefix
        if set -q _flag_p
            set out "$out"(echo -n "$_flag_p")
            if not set _flag_no_space
                set out "$out"(echo -n " ")
            end
        else if set -q _flag_P
            set out "$out"(echo -n "$_flag_p:")
            if not set _flag_no_space
                set out "$out"(echo -n " ")
            end
        end

        # name of calling function
        if set -q _flag_n
            set out "$out"(echo -n (status current-command))
            if not set _flag_no_space
                set out "$out"(echo -n " ")
            end
        else if set -q _flag_N
            set out "$out"(echo -n (status current-command))
            if not set _flag_no_space
                set out "$out"(echo -n " ")
            end
        end

        # debug-msg
        set out "$out"(echo -n "$argv")

        # appendix
        if set -q _flag_a
            set out "$out"(echo -n "$_flag_a")
        end

        # output to stderr
        if test -n "$out"
            echo "$out" >&2
        end
    end
end
