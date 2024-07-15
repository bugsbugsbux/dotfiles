function repl \
-d "Create a repl which runs the given handler function every iteration
with the user's input as arguments.

You can customize it with the following variables:
    _repl_prompt    The prompt to use if the handler did not change it
                    (by setting global _repl_prompt; only effects the
                    following iteration)
    _repl_type      How to read the input:
                    * <number> read at max <number> characters
                    * 'line' read one whole line as one argument
                    * 'token' tokenize as the shell would
                    * '' use `read`'s default behaviour
                    * <sthelse> use <sthelse> as split-delimiter
    _repl_init      Specify an initial action. Is tokenized and requires
                    fist arg to be executable.

Known issues:
    * Your last line of output will be swallowed. Therefor, your output
      has to end in a newline!
"
    # known issues:
    # * you need to end your outpout with a newline otherwise
    #   the repl overwrites the last line of your output...

    set -l _repl_prompt_default '> '

    # require a handler argument
    if not count $argv &>/dev/null; or not type -q "$argv[1]"
        echo "Error: you need to supply a valid repl-handler executable" >&2
        return
    end

    # build the repl command (puts ouput into $_repl_input)
    set -l -- _repl read --local _repl_input --list
    switch "$_repl_type" # 'line' or 'token' or 1/2/... or 'mydelimiter' or ''
        case line
            # Takes 1 line of input! If you want to read multilines try _repl_type=token
            # `$ this < (echo 1\n2 | psub)` reads 2 times 1 line,
            set -a -- _repl --line
        case token
            set -a -- _repl --tokenize
        case '*'
            # Take n characters (or less)
            if test "$_repl_type" -gt 0 2>/dev/null
                set -a -- _repl --nchars "$_repl_type"
            else
                # Split at given delimiter
                if test -n "$_repl_type"
                    set -a -- _repl --delimiter "$_repl_type"
                end
            end
    end

    # prompt
    set -a -- _repl --prompt-str
    set -l _repl_prompt_orig
    ## save original prompt
    if set -q _repl_prompt
        set -- _repl_prompt_orig "$_repl_prompt"
    else
        set -- _repl_prompt_orig "$_repl_prompt_default"
    end
    ## make sure _repl_prompt is a global, not shadowed and
    ## save the original global value
    set -elf -- _repl_prompt
    if set -qg _repl_prompt
        set -f -- _repl_prompt_orig_global "$_repl_prompt"
    end
    set -g -- _repl_prompt "$_repl_prompt_orig"

    # initial action command (parsed with fish's tokenizer)
    if set -q _repl_init
        # set -l cmd:
        echo "$_repl_init" | read --list --tokenize --local cmd
        if not type -q "$cmd[1]"
            echo "Error: \$_repl_init's command '"(echo "$cmd[1]")"' is not executable" >&2
            exit 1
        end
        $cmd
    end

    # loop
    while true

        # get input (writes to $_repl_input)
        if not $_repl "$_repl_prompt"
            # restore global prompt
            if set -qf _repl_prompt_orig_global
                set -g -- _repl_prompt "$_repl_prompt_orig_global"
            else
                set -eg -- _repl_prompt
            end

            break
        end

        # reset prompt
        set -- _repl_prompt "$_repl_prompt_orig"

        # run handler
        if not $argv $_repl_input
            # restore global prompt
            if set -qf _repl_prompt_orig_global
                set -g -- _repl_prompt "$_repl_prompt_orig_global"
            else
                set -eg -- _repl_prompt
            end

            return
        end
    end

end
