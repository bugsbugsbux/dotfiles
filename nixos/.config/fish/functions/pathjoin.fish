function pathjoin \
-d 'join args with / without worrying about wether the string end in / or not'
    set argnum (count $argv)
    if test $argnum -eq 0
        return 1
    else if test $argnum -eq 1
        if test -n "$argv[1]"
            echo $argv[1]
            return 0
        else;
            return 1;
        end
    else
        set out (string join / $argv | string replace -a // / )
        while set out (string replace // / "$out")
        end
        echo $out
        return 0
    end
    return 2 # sth unexpected happened
end
