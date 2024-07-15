function popat -S -a __index -a __var -d \
"Echo and remove (-)INDEX from VAR.
Usage: popat (-)INDEX VAR
'argv' as VAR targets caller's argv.
Fails if VAR already empty."
    if not test (count $argv) -eq 2
        echo popat: invalid number of arguments. requried: 2 >&2
        return 1
    end
    # target outer argv:
    set -el argv
    # validate args
    test -n "$__var"
    and set -q -- "$__var"
    and string match -q -r -- '-?[0-9]+' "$__index"
        or return 101
    # fail if list already empty
    set -l __n (count $$__var)
        or return 1
    # index out of range is invalid
    contains -- (math "($__index ^ 2) ^ 0.5") (seq $__n) >&2  # calculates positiv index
        or return 101
    # print and remove
    echo -- $$__var[1][$__index]
    set -e -- $__var[1][$__index]
end
