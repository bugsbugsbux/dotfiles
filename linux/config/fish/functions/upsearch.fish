function upsearch \
-d "Search upwards for a file.
Print folder containing the file
or return 1.
File can be required to be a directory.
"
    argparse "P-path=" "d/as-dir" -- $argv

    # can only search for one file
    if test (count $argv) -ne 1
        return 101
    end

    # search by default in current path
    not set -ql _flag_path
    and set -l _flag_path (pwd)
    or begin
        # given but empty -> /
        # happens because `string split / /` gives empty string
        test -z "$_flag_path"
            and set _flag_path /
    end

    # abort if cannot list folder contents
    set -l contents (ls -A "$_flag_path" 2>/dev/null)
    or return 1

    # check if already at top of filesystem
    test "$_flag_path" != '/'
    and set -l can_continue true
    or set -l can_continue false

    if not contains "$argv[1]" $contents
        $can_continue
        # recurse with parent as --path (if possible)
        and upsearch \
            $_flag_as_dir \
            --path (string split -r -m1 / "$_flag_path")[1] \
            $argv \
            && return  # reraises last exit code
        or return 1
    # found something
    else
        # special requirements to accept result?
        if set -ql _flag_as_dir
            not test -d "$_flag_path"/"$argv[1]"
            and begin
                $can_continue
                or return 1
            end
        end

        # print 
        echo -- "$_flag_path"
        return 0
    end
end
