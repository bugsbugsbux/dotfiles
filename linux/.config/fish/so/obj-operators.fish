function _with_operators -S -d "builder-extension to add operators to object"
    _builder_keep __operators
    set -ql __mixins
    and contains _operators $__mixins
        or set -a --long -- __mixins _operators
end

function _operators -S -d \
"mixin for replacing 'operators'=argv[1]
with corresponding func from __operators"
    set -el argv  # use caller's argv
    # replace argv[1] if it is a key (odd element) in __operators
    set -l __i (contains -i $argv[1] $__operators[(seq 1 2 (count $__operators))])
    and set -- argv[1] $__operators[(math "$__i * 2")]
end
