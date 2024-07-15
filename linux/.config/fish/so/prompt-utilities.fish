function _reset_prompt_state -e fish_prompt
    # overwrite old _kv_gitstate with defaults
    set -g _kv_gitstate \
        is_parsed_porcelainv2 false \
        is_parsed_stash       false \
        is_parsed_tags        false
        # stashes                0
        #
        # commit                 ""
        # branch                 ""
        # tags csv,of,this,co's,tags
        #
        # upstream               ""
        # ahead                  0
        # behind                 0
        #
        # untracked              0
        # ignored                0
        #
        # unmerged               0
        # unmerged_modified      0
        # unmerged_added         0
        # unmerged_deleted       0
        # unmerged_us            0
        # unmerged_them          0
        # unmerged_both          0
        #
        # staged                 0
        # staged_modified        0
        # staged_added           0
        # staged_deleted         0
        # staged_renamed         0
        # staged_copied          0
        # staged_chtype          0
        # staged_unknown_change  0
        #
        # unstaged               0
        # unstaged_modified      0
        # unstaged_added         0
        # unstaged_deleted       0
        # unstaged_renamed       0
        # unstaged_copied        0
        # unstaged_chtype        0
        # unstaged_unknown_change 0
        #
        # submods                0
        # changed_submods        0
        # submods_co_changed     0
        # submods_tracked        0
        # submods_untracked      0
        #
        # wt_risk none|low|medium|high|merge
end

function _set_prompt_head -v USER
    set -g __prompt_cache_head (
        begin
            # echo -n -- (set_colors normal) # dont keep color
            if _is_root
                echo -n -- (set_color -o)
                echo -n -- '#'
            else
                if string match -q -- '/dev/tty*' (tty)
                    echo -n -- (set_color -o)
                    echo -n -- '$'
                else
                    echo -n -- '❯'
                end
            end
            echo -n -- (set_color normal)" "  # end prompt with space
        end | string collect
    )
end

function _pwd_minimal
    echo -- (basename (string replace -r -- "^$HOME(?=\$|/)" "~" "$PWD"))
end

function _pwd_tilde_shrinkable -a shrunk_length -d '\
Print pwd but $HOME is ~
Supply an int to only print this many chars
for each folder.
'
    # pwd in $HOME starts with ~
    set -l pwd_tilde (string replace -r -- "^$HOME(?=\$|/)" "~" "$PWD")
    if test -n "$shrunk_length"
    and test "$shrunk_length" -gt 0
        # print path but only $shrunk_length chars of each folder name
        # except the last one. to include shrinking of the last folder
        # use this line instead of the corresponding line:
        # '}).*?(?:(?=(?<!\\\\)/)|$))') \
        echo -n -- "$pwd_tilde" | string replace -a \
            -r (string join '' \
                '/(([^/]{' \
                "$shrunk_length" \
                '}).*?(?:(?=(?<!\\\\)/)))') \
            '/$2'
    else
        echo -n -- "$pwd_tilde" # same result as piping into:
        # | string replace -a -r '/((.*?)(?:(?=(?<!\\\\)/)|$))' '/$2'
    end
end

function _parse_git_stash
    set -l stashes (git stash list --format=reference | count)
    and set _kv_gitstate (kvset stashes "$stashes" $_kv_gitstate)
    # register parsing done:
    set _kv_gitstate (kvset is_parsed_stash true $_kv_gitstate)
end

function _parse_porcelainv2 -d "\
usage: _parse_porcelainv2 OPTS
unknown options are ignored

known options:
with-tags
"

    set -l lines (
        git status --porcelain=v2 -z \
            --branch --ahead-behind \
            --show-stash \
            --untracked=normal --ignored=traditional \
            | string split0)
    while set -l line (popat 1 lines)  # this allows getting next line too
        echo -- $line | read -a -d " " -l line_elements
        switch "$line"
        case '# *'  # meta-info
            switch "$line_elements[2]"
            case branch.oid
                set _kv_gitstate (
                    kvset commit "$line_elements[3]" $_kv_gitstate)

                # this commit's TAGS:
                __porcelainv2_parse_tags

            case branch.head
                set _kv_gitstate (
                    kvset branch \
                        (string replace -r -- '^\((.*)\)$' '$1' "$line_elements[3]") \
                        $_kv_gitstate)
            case branch.upstream
                set _kv_gitstate (
                    kvset upstream "$line_elements[3]" $_kv_gitstate)
            case branch.ab
                test "$line_elements[3]" -ne 0
                and set _kv_gitstate (kvset ahead (math "0 + $line_elements[3]") $_kv_gitstate)
                test "$line_elements[4]" -ne 0
                and set _kv_gitstate (kvset behind (math "0 - $line_elements[4]") $_kv_gitstate)
            case \*
                true  # spec says to IGNORE unknown headers
            end
        case '1 *'  # changed file
            # Fix pathname
            set line_elements[9] (string join -- " " $line_elements[9..])
            # Parse:
            __porcelainv2_parse_staged_unstaged_state
            __porcelainv2_parse_submodule_state
            # IGNORE:
            # $line_elements[4] ... octal file mode in HEAD
            # $line_elements[5] ... octal file mode in index
            # $line_elements[6] ... octal file mode in worktree
            # $line_elements[7] ... object name in HEAD
            # $line_elements[8] ... object name in index
            # $line_elements[9] ... path
        case '2 *'  # renamed or copied file
            # Fix pathname
            set line_elements[10] (string join -- " " $line_elements[10..])
            # Append orig path (next line)
            set -a line (popat 1 lines)
            # Parse:
            __porcelainv2_parse_staged_unstaged_state
            __porcelainv2_parse_submodule_state
            # IGNORE:
            # $line_elements[4] ... octal file mode in HEAD
            # $line_elements[5] ... octal file mode in index
            # $line_elements[6] ... octal file mode in worktree
            # $line_elements[7] ... object name in HEAD
            # $line_elements[8] ... object name in index
            # $line_elements[9] ... copy/rename score
            __porcelainv2_parse_copy_rename_score  # yet only checks unexpected arg
            # $line_elements[10] ... new path
            # $line_elements[11] ... old path
        case 'u *'  # unmerged file
            # Fix pathname
            set line_elements[11] (string join -- " " (echo $line_elements[11..]))
            # Parse:
            __porcelainv2_parse_unmerged_state
            __porcelainv2_parse_submodule_state
            # IGNORE:
            # $line_elements[4] ... octal file mode stage 1
            # $line_elements[5] ... octal file mode stage 2
            # $line_elements[6] ... octal file mode stage 3
            # $line_elements[7] ... octal file mode in worktree
            # $line_elements[8] ... object name in stage 1
            # $line_elements[9] ... object name in stage 2
            # $line_elements[10] ... object name in stage 3
            # $line_elements[11] ... path
        case '? *'  # untracked file
            set _kv_gitstate (kvinc untracked $_kv_gitstate)
                or set _kv_gitstate (kvset untracked 1 $_kv_gitstate)
            # IGNORE: path
        case '! *'  # ignored file
            set _kv_gitstate (kvinc ignored $_kv_gitstate)
                or set _kv_gitstate (kvset ignored 1 $_kv_gitstate)
            # IGNORE: path
        case '*'  # error
            echo -- (status function): parse error for line $line >&2
            # IGNORE: path
        end
    end
    set _kv_gitstate (kvset wt_risk (
        test (kvget unmerged $_kv_gitstate; or echo 0) -gt 0
        and echo merge
        or begin
            #      [IX, WT]
            # index: 1  2
            # add indices the index if there are changes
            # and add 1
            # to get risk[($num)]: none|low|high|medium
            set -l risk none low high medium
            set -l index 0
            test (kvget staged $_kv_gitstate; or echo 0) -gt 0
                and set index 1
            echo $risk[(
                test (kvget unstaged $_kv_gitstate; or echo 0) -gt 0
                and math "$index + 3"
                or math "$index + 1"
            )]
        end
    ) $_kv_gitstate)
    # how many submodules:
    set -l -- n (git submodule status | count)
        and set _kv_gitstate (kvset submods "$n" $_kv_gitstate)
    # register parsing done:
    set _kv_gitstate (kvset is_parsed_porcelainv2 true $_kv_gitstate)
end

function __porcelainv2_parse_tags -S
    set -el argv  # gets callers argv
    contains -- with-tags $argv
        or return

    test "$line_elements[3]" != "(initial)"
    and set _kv_gitstate (
        set -l -- tags (string join , -- (
            git tag --contains "$line_elements[3]"))
        # empty tags is caught by the quotes
        kvset tags "$tags" $_kv_gitstate)
    set _kv_gitstate (kvset is_parsed_tags true $_kv_gitstate)
end

function __porcelainv2_parse_staged_unstaged_state -S
    set -l staged_unstaged_tokens (string split -- '' "$line_elements[2]")

    # Staged state:
    switch "$staged_unstaged_tokens[1]"
    case .  # unchanged
        true  # pass
    case M
        set _kv_gitstate (kvinc staged_modified $_kv_gitstate)
            or set _kv_gitstate (kvset staged_modified 1 $_kv_gitstate)
        set _kv_gitstate (kvinc staged $_kv_gitstate)
            or set _kv_gitstate (kvset staged 1 $_kv_gitstate)
    case A
        set _kv_gitstate (kvinc staged_added $_kv_gitstate)
            or set _kv_gitstate (kvset staged_added 1 $_kv_gitstate)
        set _kv_gitstate (kvinc staged $_kv_gitstate)
            or set _kv_gitstate (kvset staged 1 $_kv_gitstate)
    case D
        set _kv_gitstate (kvinc staged_deleted $_kv_gitstate)
            or set _kv_gitstate (kvset staged_deleted 1 $_kv_gitstate)
        set _kv_gitstate (kvinc staged $_kv_gitstate)
            or set _kv_gitstate (kvset staged 1 $_kv_gitstate)
    case R
        set _kv_gitstate (kvinc staged_renamed $_kv_gitstate)
            or set _kv_gitstate (kvset staged_renamed 1 $_kv_gitstate)
        set _kv_gitstate (kvinc staged $_kv_gitstate)
            or set _kv_gitstate (kvset staged 1 $_kv_gitstate)
    case C
        set _kv_gitstate (kvinc staged_copied $_kv_gitstate)
            or set _kv_gitstate (kvset staged_copied 1 $_kv_gitstate)
        set _kv_gitstate (kvinc staged $_kv_gitstate)
            or set _kv_gitstate (kvset staged 1 $_kv_gitstate)
    case T
        set _kv_gitstate (kvinc staged_chtype $_kv_gitstate)
            or set _kv_gitstate (kvset staged_chtype 1 $_kv_gitstate)
        set _kv_gitstate (kvinc staged $_kv_gitstate)
            or set _kv_gitstate (kvset staged 1 $_kv_gitstate)
    case X
        set _kv_gitstate (kvinc staged_unknown_change $_kv_gitstate)
            or set _kv_gitstate (kvset staged_unknown_change 1 $_kv_gitstate)
        set _kv_gitstate (kvinc staged $_kv_gitstate)
            or set _kv_gitstate (kvset staged 1 $_kv_gitstate)
        contains -- "$SUPPRESS_PORC_ERR_UNKNOWN" true 1
            or begin
                echo -n -- (set_color normal)(set_color red)
                echo -- (status function): porcelain detects unknown change:
                echo -- $line
                echo -- (set_color -o)PROBABLY GIT BUG, PLEASE REPORT!(set_color normal)(set_color red)
                echo -- Suppress this with 'set $SUPPRESS_PORC_ERR_UNKNOWN true'
                echo -n -- (set_color normal)
            end >&2
    case '*'
        echo -- (status function): parse error for line $line >&2
    end

    # Unstaged state:
    switch "$staged_unstaged_tokens[2]"
    case .  # unchanged
        true  # pass
    case M
        set _kv_gitstate (kvinc unstaged_modified $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged_modified 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unstaged $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged 1 $_kv_gitstate)
    case A
        set _kv_gitstate (kvinc unstaged_added $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged_added 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unstaged $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged 1 $_kv_gitstate)
    case D
        set _kv_gitstate (kvinc unstaged_deleted $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged_deleted 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unstaged $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged 1 $_kv_gitstate)
    case R
        set _kv_gitstate (kvinc unstaged_renamed $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged_renamed 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unstaged $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged 1 $_kv_gitstate)
    case C
        set _kv_gitstate (kvinc unstaged_copied $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged_copied 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unstaged $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged 1 $_kv_gitstate)
    case T
        set _kv_gitstate (kvinc unstaged_chtype $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged_chtype 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unstaged $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged 1 $_kv_gitstate)
    case X
        set _kv_gitstate (kvinc unstaged_unknown_change $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged_unknown_change 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unstaged $_kv_gitstate)
            or set _kv_gitstate (kvset unstaged 1 $_kv_gitstate)
        contains -- "$SUPPRESS_PORC_ERR_UNKNOWN" true 1
            or begin
                echo -n -- (set_color normal)(set_color red)
                echo -- (status function): porcelain detects unknown change:
                echo -- $line
                echo -- (set_color -o)PROBABLY GIT BUG, PLEASE REPORT!(set_color normal)(set_color red)
                echo -- Suppress this with 'set $SUPPRESS_PORC_ERR_UNKNOWN true'
                echo -n -- (set_color normal)
            end >&2
    case '*'
        echo -- (status function): parse error for line $line >&2
    end
end

function __porcelainv2_parse_submodule_state -S
    set -l submodule_tokens (string split -- '' "$line_elements[3]")
    set -l e; for e in $submodule_tokens
        contains "$e" "." N S C U M
        or echo -- (status function): \
            "parse error for tokens $submodule_tokens" >&2 && break
    end
    test "$submodule_tokens[1]" = S
        or return             # = N; not a submodule
        and set _kv_gitstate (kvinc changed_submods $_kv_gitstate)
            or set _kv_gitstate (kvset changed_submods 1 $_kv_gitstate)
    test "$submodule_tokens[2]" = C
        and set _kv_gitstate (kvinc submods_co_changed $_kv_gitstate)
            or set _kv_gitstate (kvset submods_co_changed 1 $_kv_gitstate)
    test "$submodule_tokens[3]" = M
        and set _kv_gitstate (kvinc submods_tracked $_kv_gitstate)
            or set _kv_gitstate (kvset submods_tracked 1 $_kv_gitstate)
    test "$submodule_tokens[4]" = U
        and set _kv_gitstate (kvinc submods_untracked $_kv_gitstate)
            or set _kv_gitstate (kvset submods_untracked 1 $_kv_gitstate)
end

function __porcelainv2_parse_copy_rename_score -S
    # I dont know yet what to use this for, so for now this only
    # serves as check wether there is an unexpected state-str:
    switch (string sub -l 1 -- "$line_elements[9]")
    case R
        true # <obj> _set copy_rename_type rename
    case C
        true # <obj> _set copy_rename_type copy
    case '*'
        echo -- (status function): parse error for string $line_elements[9] >&2
    end
    # <obj> _set copy_rename_similarity (string sub -s 2 -- "$line_elements[9]")
end

function __porcelainv2_parse_unmerged_state -S
    # Check wether there is an unexpected state-str
    # Unneeded if the switch-statement is uncommented
    contains -- "$line_elements[2]" UU AA DD AU UA DU UD
        or echo -- (status function): parse error - \
            unexpected case: "'$line_elements[2]'" >&2

    set _kv_gitstate (kvinc unmerged $_kv_gitstate)
        or set _kv_gitstate (kvset unmerged 1 $_kv_gitstate)

    switch "$line_elements[2]"
    case UU # ... unmerged, both modified
        set _kv_gitstate (kvinc unmerged_modified $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_modified 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unmerged_both $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_both 1 $_kv_gitstate)
    case AA # ... unmerged, both added
        set _kv_gitstate (kvinc unmerged_added $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_added 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unmerged_both $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_both 1 $_kv_gitstate)
    case DD # ... unmerged, both deleted
        set _kv_gitstate (kvinc unmerged_deleted $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_deleted 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unmerged_both $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_both 1 $_kv_gitstate)
    case AU # ... unmerged, added by us
        set _kv_gitstate (kvinc unmerged_added $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_added 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unmerged_us $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_us 1 $_kv_gitstate)
    case UA # ... unmerged, added by them
        set _kv_gitstate (kvinc unmerged_added $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_added 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unmerged_them $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_them 1 $_kv_gitstate)
    case DU # ... unmerged, deleted by us
        set _kv_gitstate (kvinc unmerged_deleted $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_deleted 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unmerged_us $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_us 1 $_kv_gitstate)
    case UD # ... unmerged, deleted by them
        set _kv_gitstate (kvinc unmerged_deleted $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_deleted 1 $_kv_gitstate)
        set _kv_gitstate (kvinc unmerged_them $_kv_gitstate)
            or set _kv_gitstate (kvset unmerged_them 1 $_kv_gitstate)
    case '*'
        echo -- (status function): \
            parse error - unexpected case: "'$line_elements[2]'" >&2
    end
end

function _is_root
    contains -- "$USER" root toor Admin Administrator Superuser
end

function _is_git_worktree
    set -l bool (git rev-parse --is-inside-work-tree 2>/dev/null)
    test "$bool" = true
    or return 1
end

function _is_the_git_dir -d "Success if in .git/"
    set -l bool (git rev-parse --is-inside-git-dir 2>/dev/null)
    test "$bool" = true
end

function _has_dockerfile
    contains Dockerfile (ls)
end

function _has_makefile
    contains Makefile (ls)
end

function _is_dart_project
    upsearch pubspec.yaml &>/dev/null
end

function _is_python_project
    begin
           upsearch requirements.txt
        or upsearch .python-version
        or upsearch pyproject.toml
        or upsearch setup.py
        or upsearch tox.ini
        or upsearch Pipfile
        or upsearch .pypirc
    end &>/dev/null
end

function _get_explicit_pyver
    type -q pyenv &>/dev/null
        or return 100
    set -l pyver (pyenv version-name)
    test "$pyver" != system
        or return 1
    echo -- "$pyver"
end

function _get_venv_name
    type -q pyenv &>/dev/null
    and contains -- virtualenvs (pyenv commands)
    or return 100
    pyenv virtualenvs | __parse_pyenv_current
end

function __parse_pyenv_current -d "\
Pipe output of `pyenv versions` or `pyenv virtualenvs`
into this to parse it.
"
    while read -L -l line
        if string match -q -- '\* *' "$line"
            set -l -- name (string split -f 2 -- ' ' "$line")
            set -l -- slash_splitted (string split -m 1 -r -f 2 / "$name")
            and echo -- "$slash_splitted"
            or echo -- "$name"
            return 0
        end
    end
    return 1
end
