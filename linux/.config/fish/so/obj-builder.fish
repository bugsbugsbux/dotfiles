function _builder_keep -S -d "Builder extension for preserving a variable."
    test (count $argv) -eq 1
    and test -n "$argv[1]"
        or return 101
    set -ql $argv[1]
        and echo -n -- 'set --local --long -- '"$argv[1]" (
            echo -n -- (string escape --style=script -- $$argv[1])) \
            && echo  # EOL
end

function _rebuild -S -d \
"Rebuild the object with the current state by calling
it's builder.

A function defining the (re)build behaviour of an object
is called BUILDER. _rebuild comes with a default builder
which can be overridden with a callable in __builder.

Instead of writing a completely new builder you can
extend the default builder with BUILDER-EXTENSIONS.
Name them in __builder_extensions. They will be
executed before items are set during build-time.

Instead of writing logic into the object definition
call any executable as command on the object. Function
_this expands a call with a function from __methods.

Commands are run with 'eval'. If you want to change
that simply specify a runner function in __runner
and it will be run with argv as arguments instead.
"
    set -ql __name
        or return 1

    # Run custom builder:
    if set -ql __builder
    and test -n "$__builder"
        eval $__builder
        return
    end

                ##### DEFAULT BUILDER #####
    begin
        echo -- "function $__name"
        echo -- 'set --local --long --export -- __name (status function)'

        # Run the builder extensions now (BUILDTIME):
        set -ql __builder_extensions
            and eval {$__builder_extensions}\;

        # Keep these variables
        eval _builder_keep\ {__builder,__builder_extensions,__mixins,__runner}\;

        # Add the items:
        for __k in (_keys)
            echo -n -- "set --local --long -- $__k"
            # Don't escape zero-element values - they
            # would become empty-string elements:
            _get "$__k" &>/dev/null
            and for __e in (_get "$__k" | string split0 --)
                echo -n " "
                echo -n -- (string escape --style=script -- $__e)
            end
            echo  # EOL
        end

        # Add mixins to be evaluated at RUNTIME:
        echo -- eval (string join \n {$__mixins}\; | string collect)

        # Add command call (possible interception by $__runner):
        echo -- 'eval $__runner $argv'

        echo -- end
    end | source
end
