function show_theme
    set -l docstring "\
This prints text in the default color as well as
all 8 basic colors and their dim and bright variants.
All 8 basic colors and their bright version are used as
backgrounds as well as one column without background.

You can alter a color's definition by supplying the name
and the new definition as 2 consecutive further arguments
to this function.
Redifining 'normal' or defining a color
as 'normal' is not allowed.

Valid color-names:
black   brblack
red     brred
green   brgreen
yellow  bryellow
blue    brblue
magenta brmagenta
cyan    brcyan
white   brwhite

Options:
-h --help       Print this helptext and exit successfully
-b --brbg       Print table with bright bg
-B --with-brbg  Print table with normal and bright bg
-f --fg-brightness <csv>
                How many, which and order of foreground
                brightnesses to use.
                Available are: de[fault]/n[ormal],b[right],d[im]
                If this flag is not specified all are shown

Example: `\$ "(status function)" -B brblue --fg dim,normal \#abcdef blue 123`
"
    functions -d "$docstring" (status function)

    # defaults:
    #--+----------++---------+---------+---------+---------+---------+---------+---------+-----------+
    #--| varname  ||  black  |   red   |  green  | yellow  |  blue   | magenta |  cyan   |  white   #|
    #--+----------++---------+---------+---------+---------+---------+---------+---------+-----------+
    set colornames  black       red      green     yellow     blue    magenta     cyan      white   #|
    set colors      black       red      green     yellow     blue    magenta     cyan      white   #|
    set brcolors    brblack     brred    brgreen   bryellow   brblue  brmagenta   brcyan    brwhite #|
    #--+----------++---------+---------+---------+---------+---------+---------+---------+-----------+

    # handle args
    ## defaults
    set -l __opt_bgnormal true
    set -l __opt_bgbright false
    set -l __opt_fgbrightness normal bright dim
    ## get flags
    set -l n (count $argv)
    set -l i 0
    set -l to_delete
    while test "$i" -le "$n"
        set i (math "$i + 1")
        string match -q -e -- "-*" "$argv[$i]"
        or continue
        switch "$argv[$i]"
        case -h --help
            echo -- $docstring
            return 0
        case -b --brbg
            set -a to_delete $i
            set __opt_bgnormal false
            set __opt_bgbright true
        case -B --with-brbg
            set -a to_delete $i
            set __opt_bgnormal true
            set __opt_bgbright true
        case -f --fg
            # save index of value and skip it in next loop too
            set -l i_argval (math "$i + 1")
            set -a to_delete $i $i_argval
            set -l i $i_argval
            # if this flag is given only print specified foregrounds
            set __opt_fgbrightness  # clear
            set -l argvals (string split -- , "$argv[$i_argval]")
            for val in $argvals
                switch "$val"
                case n no normal de default
                    set -a __opt_fgbrightness normal
                case b br bright
                    set -a __opt_fgbrightness bright
                case di dim
                    set -a __opt_fgbrightness dim
                case \*
                    return 101
                end
            end
        case \*
            return 101
        end
    end
    ## remove the flags
    for i in $to_delete[-1..1]  # reverse! otherwise would indices change
        set -e argv[$i]
    end
    ## override colors with supplied values
    while set -l colorname (popat 1 argv)
        set -l colorval (popat 1 argv)
            or echo -- error: uneven key-value list >&2 && return 101
        not contains -- normal "$colorname" "$colorval"
            or echo -- "error: 'normal' not allowed as colorname or -value" >&2 && return 101
        if set -l -- i (contains -i -- "$colorname" $colornames)
            update_color
        else if set -l -- i (contains -i -- (string sub -s 3 -- "$colorname") $colornames)
            update_color --bright
        else
            echo -- "error: invalid colorname '$colorname'" &>2
            return 101
        end
    end

    # header
    echo -- "\
       | none  | black | red   | green | yellow| blue  |magenta| cyan  | white |
-------+-------+-------+-------+-------+-------+-------+-------+-------+-------+"

    $__opt_bgnormal
        and print_colorscheme colors
    $__opt_bgbright
        and print_colorscheme brcolors

    set -l rv $status
    test $rv -eq 1
        and return 0
    or return $rv
end

function update_color -S -d "redefine a color"
    # handle args
    set -l var colors
    test "$argv[1]" = "--bright"
        and set var brcolors

    # validate colorval
    if string match -q -r '^#?(?:[a-fA-F0-9]{3}){1,2}$' "$colorval"
    or contains -- "$colorval" {br,}$colornames
        # set colorval
        set -- "$var"[$i] "$colorval"
    else
        echo "error: invalid colorvalue '$colorval'" >&2
        return 101
    end
end

function print_text -S -d 'print 8 chars: $fg_color_name (+ spaces if necessary)'
    echo -n -- (string pad -r -w 8 -- (string sub -l 8 -- "$fg_color_name"))
end
function eol -S -d "print newline, reset background and colors/formatting"
    set without_bg true
    echo -n -- (set_color normal)
    echo  # EOL
end
function print_colorscheme -S -a var_bg_colors
    test -n "$var_bg_colors"
    and set -q "$var_bg_colors"
    and test -n "$$var_bg_colors"
        or return 101

    for i in (seq 0 8)  # = fg-color-index for lines

        # no explicit fg color:
        if test $i -eq 0
            set -l fg_color_name default

            for fgbrightness in $__opt_fgbrightness
                switch "$fgbrightness"
                case normal
                    # fg just colorized
                    fg_color_name=normal: print_text  # label
                    # without explicit bg
                    echo -n -- (set_color -o)
                    print_text
                    # with explicit bg
                    for bg_color in $$var_bg_colors
                        echo -n -- (set_color -b "$bg_color" -o)
                        print_text
                        echo -n -- (set_color normal)
                    end
                    eol
                case dim
                    # dim fg
                    fg_color_name="dim   :" print_text  # label
                    # without explicit bg
                    echo -n -- (set_color -o --dim)
                    print_text
                    # with explicit bg
                    for bg_color in $$var_bg_colors
                        echo -n -- (set_color -b "$bg_color" --dim -o)
                        print_text
                        echo -n -- (set_color normal)
                    end
                    eol
                case bright
                    # we cant know the bright version of the default color
                    continue
                case \*
                    return 101
                end
            end
            continue
        end

        set -l fg_color_name "$colornames[$i]"
        set -l fg_color "$colors[$i]"
        set -l fg_color_bright "$brcolors[$i]"

        echo -n -- (set_color normal)

        ## explicit fg color:
        set -l without_bg true

        for fgbrightness in $__opt_fgbrightness
            switch "$fgbrightness"
            case normal
                fg_color_name=normal: print_text  # label
                for bg_color in normal $$var_bg_colors
                    $without_bg
                    and echo -n (set_color -o "$fg_color") && set without_bg false
                    or echo -n -- (set_color -b "$bg_color" -o "$fg_color")
                    print_text
                end
                eol

            case bright
                fg_color_name=bright: print_text  # label
                for bg_color in normal $$var_bg_colors
                    $without_bg
                    and echo -n (set_color -o "$fg_color_bright") && set without_bg false
                    or echo -n -- (set_color -b "$bg_color" -o "$fg_color_bright")
                    print_text
                end
                eol

            case dim
                fg_color_name="dim   :" print_text  # label
                for bg_color in normal $$var_bg_colors
                    $without_bg && set without_bg false
                    or echo -n -- (set_color -b "$bg_color")

                    echo -n -- (set_color --dim -o "$fg_color")
                    print_text
                end
                eol
            case \*
                return 101
            end
        end
    end

end
