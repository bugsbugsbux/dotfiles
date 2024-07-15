function new -a __name  # no -S
# rebuild this as object with name $__name
    test -n "$__name"
    and not functions -q "$__name"
        or return 101
    _rebuild
end

function _keys -S -d \
"Return list of keys. Fail if it is empty.
Keys must not match 'argv' or glob '__*'"
    string match -v -r '^argv$|^__.*' (set -nl)
end

function _get -S -d \
'Return null-separated value of KEY (This allows multiline strings).
1   ... KEY has **NO VALUE (!= empty string)**
101 ... KEY does not exist (Query key with `contains key (D _keys)`).'
    test (count $argv) -eq 1
    and test -n "$argv[1]"
    and contains -- $argv[1] (_keys)
        or return 101
    string join0 -- $$argv[1]          # Error on zero- AND one-element values.
        or count $$argv[1] &>/dev/null # Now ONLY on zero-emelent values.
end

function _set -S
    test -n "$argv[1]"
    and string match -q -v -r -- '^argv$|^__.*$' "$argv[1]"
        or return 101
    set -l -- "$argv[1]" $argv[2..-1]
    _rebuild
end

function _del -S
    test -n "$argv[1]"
    and test (count $argv) -eq 1
    and contains "$argv[1]" (_keys)
        or return 101
    set -el -- "$argv[1]"
    _rebuild
end
