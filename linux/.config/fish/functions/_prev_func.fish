function _prev_func
    set -l docstring "\
Usage:
_prev_func [-h/--help] [-INT]

Get n-th last function's name from stack.
By default INT=1 == caller's parent.

Error.1 if there is no n-th last function.

Options:
-INT       Request n-th last function (not counting
           the caller).
-h --help  Print this help text and exit.0 .
"
    functions -d "$docstring" (status function)

    argparse h/help '#-nth!_validate_int' -- $argv

    if set -ql _flag_help
        echo -- "$docstring"
        return 0
    end

    # Default to third last func = caller's parent
    set -l __nth 3
    if set -ql _flag_nth
        # If specified add 2 (for self and caller).
        set __nth (math $_flag_nth + 2)
    end

    # Filter callstack:
    set -l stack_functions
    status stack-trace |
        grep 'in function' |   # filter for functions
        while read -l line
            set -a -- stack_functions $line
        end

    # Error if there is no nth-function.
    set -l num_funcs (count $stack_functions)
    test "$num_funcs" -ge "$__nth"
        or return 1

    # Extract and output name
    echo -- $stack_functions[$__nth] |
        read --local --list --tokenize __prevfunc   # split and save
    and echo -- $__prevfunc[3] # output name
    or return 100
end

