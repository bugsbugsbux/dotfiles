function fishpaste \
-d "paste something into your fish-terminal or a file"
    argparse -n (status function) -x o,a f/file= o/overwrite a/append -- $argv
    if set -ql _flag_file
        if set -ql _flag_overwrite
            cat <(cat - | psub) > $_flag_file
        else
            if set -ql _flag_append
                cat <(cat - | psub) >> $_flag_file
            else
                cat <(cat - | psub) >? $_flag_file
            end
        end
    else
        cat <(cat - | psub)
    end
end
