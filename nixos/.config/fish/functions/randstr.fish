function randstr -S \
-d 'get a random string [0-9a-zA-Z] as variable/function name'

    function __randstr
        argparse --name randstr \
            -x p,P \
            -x l,g \
            -x f,s -x f,l -x f,g \
            'h/help' \
            'L/length=!_validate_int --min 1' \
            'p/private' \
            'P/very-private' \
            'v/var' \
            'V/exclude-contents=+' \
            'f/func' \
            'e/exclude=+' \
            'E/exclude-contents=+' \
            's/setter' \
            'l/setter-local' \
            'g/setter-global' \
            -- $argv

        if set -ql _flag_help
            echo -- "\
randstr: get a random string

options:
-h/--help           print this help text
-L/--length=        length of the var without a prefix
-p/--private        prefix with '_'
-P/--very-private   prefix with '__'
-v/--var            disallow existing variable names
-f/--func           disallow existing function names
-e/--exclude=+      disallow this string
-E/--exclude-contents=+
                    treat as var and disallow its elements.
-s/--setter         print with sourceable setter
-l/--setter-local   print with sourceable local setter
-g/--setter-global  print with sourceable global setter
"

            return 0
        end

        # default length
        not set -ql _flag_length
        and set -l _flag_length 10

        # prefix?
        set -ql _flag_private
        and set -l prefix '_'
        set -ql _flag_very_private
        and set -l prefix '__'

        while true
            # get a random string with chosen prefix
            set -l v "$prefix"(cat /dev/urandom |
                tr -dc '0-9a-zA-Z' |
                head -c "$_flag_length")

            # check explicitly disallowed names
            if contains "$v" $_flag_exclude
            or contains "$v" $$_flag_exclude_contents
                continue
            end

            # existing function names
            if set -ql _flag_func
                if functions -q --all "$v"
                    continue
                end
            end

            # existing variable names
            if set -ql _flag_var
            or set -ql _flag_setter
            or set -ql _flag_setter_local
            or set -ql _flag_setter_global
                if set -q "$v"
                or contains "$v" $_flag_exclude_contents
                    continue
                end
            end

            # output and exit successfully
            if set -ql _flag_setter_global
                echo -- set -g -- "'$v'"
            else if set -ql _flag_setter_local
                echo -- set -l -- "'$v'"
            else if set -ql _flag_setter  # has to be checked last
                echo -- set -- "'$v'"
            else
                echo "$v"
                return 0
            end
            # only reached if returning a setter:
            echo -- echo -- "'$v'"
            return 0
        end
    end

    # call randstr and add current locals to exclude list
    __randstr $argv (
        for v in (set -nl)
            echo -- -V $v
        end
    )
    return $status
end
