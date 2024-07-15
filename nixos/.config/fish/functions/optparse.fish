function optparse \
-d "argparse alternative based on argparse
fixing some issues i have with argparse: mainly scoping

USAGE:
1. write optspec
2. call optparse and save its output
3. eval the output"

    # save and clear argv
    set args $argv
    set -e argv

    set endoptspec (contains -i -- '--' $args)

    # extract optparse specific options from $args
    argparse \
        --ignore-unknown \
        h/help \
        l/local \
        g/group=+ \
        a/argparse-compatible \
        -- $args[1..(math $endoptspec - 1)]

    if set -q _flag_group
        echo option grouping not implemeted yet. >&2
        return 102
    end
    if not set -q _flag_argparse_compatible
        echo argparse incompatible mode not implemeted yet. use -a >&2
        return 102
    end

    # put args back together without the extracted options
    set args $argv $args[$endoptspec..-1]
    set -e argv

    # rename options to not use _flag_ so '_flag_' can be greped for later
    for v in (set -nl | grep _flag_)
        set -l option (string split -m 1 -n '_flag_' $v)
        if not test (count $option) -eq 1
            return 101
        end
        set $option $$v
        set -e $v
    end; set -el v

    # actual parsing
    argparse $args

    # build output complying given with optparse-options
    set out
    if set -q local
        set setter "set -l"
    else
        set setter "set"
    end
    set -a out "$setter argv $argv ;"
    for v in (set -nl | grep _flag_)
        set -a out "$setter $v $$v ;"
    end; set -el v

    # output result
    for flag in $out
        echo $flag
    end
end
