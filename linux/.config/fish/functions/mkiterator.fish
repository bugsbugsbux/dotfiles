# dependencies: randstr.fish

function mkiterator \
-d "Create an iterator function and echos it's name.
For comfortable usage assign it to a variable or an alias"

    # set the init state
    set -l elements $argv
    set -l length (count $elements)
    test $length -eq 0
        and return 101
    set -l exhausted (math $length + 1)
    set -l pcurrent (mkgvar -P)
    set -g $pcurrent 0

    # define the iterator
    set name (randstr -P -f)
    function $name \
    -d "This is an iterator. Call it with next or previous
    as an argument to get the next element.
    `next` exits with 3 if there is no next element and puts
    the cursor at len+1;
    `previous` exits with 2 if no previous element and puts
    the cursor at 0" \
     -V name -V elements -V pcurrent -V length -V exhausted \
    -a subcmd
        set -l self $name
        switch "$subcmd"
            case cur current get
                __iter_get_or_reset
                return $status
            case ne next
                set -g $pcurrent (math $$pcurrent + 1)
                __iter_get_or_reset
                return $status
            case pre prev previous
                set -g $pcurrent (math $$pcurrent - 1)
                __iter_get_or_reset
                return $status
            case state get-state
                set -l x (__iter_get_or_reset)
                set -l rv $status
                not contains -- "$argv[2]" "-q" "--quiet"
                    and echo $$pcurrent
                return $rv
            case set set-state
                test "$argv[2]" -ge "-1" -a "$argv[2]" -le $exhausted
                    or return 101
                if test $argv[2] -eq -1
                    set -g $pcurrent $length
                else
                    set -g $pcurrent $argv[2]
                end
                return 0
            case dest destroy destroy-self
                set -eg $pcurrent
                functions -e $self
            case '*'
                echo "unknown option $subcmd" >&2
                return 101
        end
    end
    or return 101

    # echo the iterator
    echo $name
end

function __iter_get_or_reset -S \
-d "
* This expects to find the variables
  'elements', 'exhausted' and 'pcurrent' in
  the calling function.
* This ensures that an out-of-range pcurrent is
  exactly off by 1.
* This echos the element at index \$\$pcurrent
  or returns 2 if index is too low
  and 3 if index is too high.
"
    if test $$pcurrent -gt 0 -a $$pcurrent -lt $exhausted
        echo $elements[$$pcurrent]
        return 0
    else  # index out of range
        if test $$pcurrent -ge $exhausted
            set -g $pcurrent $exhausted  # ensure off-by-one
            return 3
        else if test $$pcurrent -le 0
            set -g $pcurrent 0  # ensure off-by-one
            return 2
        else
            echo "unhandled case in ( line"\
                (status line-number)" in file "(status filename)")" >&2
            return 100
        end
    end
    return 100  # shouldnt be reached
end
