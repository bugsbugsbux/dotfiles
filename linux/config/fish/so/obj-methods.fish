function _with_methods -S -d "builder-extension to add methods to object"
    _builder_keep __methods
end

function _this -S -d "call correct func from __methods instead of argv[1]"
    set -ql __methods
        or return 100
    type -q "$argv[1]"
    and set -l -- ___ (kvget -q "$argv[1]" $__methods) $argv[2..-1]
        or return 101
    set -el argv
    eval $___
end

