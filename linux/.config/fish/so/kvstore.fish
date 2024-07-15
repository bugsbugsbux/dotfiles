function kvkeys -d \
"Echo list of keys (=odd elements).
Fail:1 on empty list.
"
    set -l length (count $argv)
        or return 1
    string join -- \n $argv[(seq 1 2 $length)]
end

function kvvals -d \
"Echo list of values (=even elements).
Fail:1 on empty list.
"
    set -l length (count $argv)
        or return 1
    string join -- \n $argv[(seq 2 2 $length)]
end

function kvitems -d \
"Echo a list of key-value pairs.
Override var SEP with a separator of your liking.
Default 'SEP' is \t.
Fail:1 if list is empty.
"
    set -ql SEP
        or set -l SEP \t
    set -l length (count $argv)
        or return 1
    set -l -- vals (kvvals $argv)
    for key in (kvkeys $argv)
        string join -- "$SEP" "$key" "$vals[1]"
        set -e vals[1]
    end
end

function kvget -a key -d \
"Echo the value or index of one item KEY.
Fail:1 if item KEY not found.
Usage: kvget [OPTS] KEY list...
OPTS:
--             End of options.
-i --index     Echo the index of the item's *value*
-I --index-key Echo the index of the item's *key*
-q --quiet     Don't echo anything. Useful to just
        check wether a key exists.
"
    test (count $argv) -ge 1
        or begin
            echo error: missing positional arg 1:KEY >&2
            return 101
        end
    # parse flags
    set -l __flag_index     false
    set -l __flag_index_key false
    set -l __flag_quiet     false
    # <++ todo: add option to treat empty string as no value>
    while string match -q -- '-*' $argv[1]
        switch "$argv[1]"
        case -i --index
            set __flag_index[1] true
        case -I --index-key
            set __flag_index_key[1] true
        case -q --quiet
            set __flag_quiet[1] true
        case --
            set -e argv[1]
            break
        case '*'
            echo -- error: unknown option "$argv[1]" >&2
            return 101
        end
        set -e argv[1]
    end
    # fix argument 'key' and remove it from argv
    set -- key "$argv[1]"
    set -e argv[1]
    # forbid: --index with --index-key
    if $__flag_index[1]
    and $__flag_index_key[1]
        echo error: invalid option combination >&2
        return 101
    end
    # forbid: --index or --index-with with --quiet
    if $__flag_index[1]
    or $__flag_index_key[1]
    and $__flag_quiet[1]
        echo error: invalid option combination >&2
        return 101
    end

    if set -l i (contains -i -- "$key" (kvkeys $argv))
    # key found:
        if $__flag_quiet[1]
            :  # pass
        else if $__flag_index[1]
            echo (math "$i * 2")
        else if $__flag_index_key[1]
            echo (math "$i * 2 - 1")
        else
            echo -- $argv[(math "$i * 2")]
        end
        return 0
    else
    # key not found:
        if $__flag_index[1]
        or $__flag_index_key[1]
            echo 0
        end
        return 1
    end
end

function kvset -a key -a value -d \
"Either update *item* KEY or add it.
You have to supply a key and value.
"

    # check args
    test (count $argv) -ge 2
        or begin
            echo error: missing positional args 1:KEY and/or 2:VALUE >&2
            return 101
        end
    # make argv just the key-value-list
    set -e argv[1 2]

    # set the key in argv
    set -l -- __i (kvget --index "$key" $argv)
    and set -- argv[$__i] "$value"
    or set -a -- argv "$key" "$value"

    string join -- \n $argv
end

function kvdel -a key -d \
"Remove the *item* KEY from the key-value-list.
"
    # check args
    test (count $argv) -ge 1
        or begin
            echo error: missing positional arg 1:KEY >&2
            return 101
        end
    # make argv just the key-value-list
    set -e argv[1]

    # delete item from argv
    set -l -- __i (kvget --index-key -- "$key" $argv)
    and set -e -- argv[$__i] && set -e -- argv[$__i]
    or begin
        # return original list
        string join -- \n $argv
        return 1
    end

    # output
    string join -- \n $argv
end

function kvinc -a key -d "\
Increment value of KEY by 1
or fail.1 if KEY does not exists
or fail.2 if KEY does not contain a number
Note:
+ Empty strings can be incremented!
+ You may override INC with negative numbers.
    eg: `INC=-5 kvinc x \$kv`
"
    test (count $argv) -ge 1
        or begin
            echo error: missing positional arg 1:KEY >&2
            return 101
        end
    # make argv just the key-value-list
    set -e argv[1]
    # make sure KEY is a key in argv
    contains -- "$key" (kvkeys $argv)
        or begin
            # return original list
            string join -- \n $argv
            return 1
        end

    # the amount to increment can be overridden:
    set -ql INC
        or set -l INC 1

    set -l new (math (kvget "$key" $argv | string collect) "+ $INC")
    and kvset "$key" "$new" $argv
    or begin
        string join -- \n $argv
        return 2
    end
end
