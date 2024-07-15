function fish_prompt
    set -l stati $status $pipestatus
    set -l laststatus $stati[1]
    set -l lastpipestatus $stati[2..]

    # The last status shall be shown if there was an error (even if
    # last command in pipe was successful).
    # If last command was pipe ! is added,
    # if $status is not $pipestatus[-1] !! is added
    set -l segment_status (set_color -o red)
    if test (math (string join + $stati; or echo 0)) -ne 0
        set segment_status "$segment_status"'('"$laststatus"
        if test (count $lastpipestatus) -gt 1
            set segment_status "$segment_status"'!'
        end
        if test $laststatus -ne $lastpipestatus[-1]
            set segment_status "$segment_status"'!!'
        end
        set segment_status "$segment_status"')'
    end
    set segment_status "$segment_status"(set_color normal)

    set -l segment_cwd (pwd | string replace -- "$HOME" '~')
    echo -n -- "$segment_cwd"' '"$segment_status"'❯ '
    return

    set -l lastpipestatus $pipestatus
    set -l laststatus $status  # != $pipestatus[-1] if `not` was used
    set -qg __prompt_cache_head
        or _set_prompt_head

    # THEME: set custom colors to the theme_* variables:
    set -l theme_black     black
    set -l theme_red       red
    set -l theme_green     green
    set -l theme_yellow    yellow
    set -l theme_blue      blue
    set -l theme_magenta   magenta
    set -l theme_cyan      cyan
    set -l theme_white     white
    # bright versions:
    set -l theme_brblack   brblack
    set -l theme_brred     brred
    set -l theme_brgreen   brgreen
    set -l theme_bryellow  bryellow
    set -l theme_brblue    brblue
    set -l theme_brmagenta brmagenta
    set -l theme_brcyan    brcyan
    set -l theme_brwhite   brwhite
    # orange
    set -l theme_orange    FFA500
    set -l theme_brorange  FFA400

    # COLORS: use these to style output
    #     |COLOR NAMES| definitions (inherited from theme)
    # ====|===========|===================================
    # not colors:
    set -l reset       (set_color normal                       )
    set -l reverse     (set_color --reverse                    )
    set -l fat         (set_color --bold                       )
    set -l dim         (set_color --dim                        )
    #
    set -l black       (set_color $theme_black                 )
    set -l red         (set_color $theme_red                   )
    set -l green       (set_color $theme_green                 )
    set -l yellow      (set_color $theme_yellow                )
    set -l blue        (set_color $theme_blue                  )
    set -l magenta     (set_color $theme_magenta               )
    set -l cyan        (set_color $theme_cyan                  )
    set -l white       (set_color $theme_white                 )
    set -l bgblack     (set_color --background $theme_black    )
    set -l bgred       (set_color --background $theme_red      )
    set -l bggreen     (set_color --background $theme_green    )
    set -l bgyellow    (set_color --background $theme_yellow   )
    set -l bgblue      (set_color --background $theme_blue     )
    set -l bgmagenta   (set_color --background $theme_magenta  )
    set -l bgcyan      (set_color --background $theme_cyan     )
    set -l bgwhite     (set_color --background $theme_white    )
    set -l brblack     (set_color $theme_brblack               )
    set -l brred       (set_color $theme_brred                 )
    set -l brgreen     (set_color $theme_brgreen               )
    set -l bryellow    (set_color $theme_bryellow              )
    set -l brblue      (set_color $theme_brblue                )
    set -l brmagenta   (set_color $theme_brmagenta             )
    set -l brcyan      (set_color $theme_brcyan                )
    set -l brwhite     (set_color $theme_brwhite               )
    set -l bgbrblack   (set_color --background $theme_brblack  )
    set -l bgbrred     (set_color --background $theme_brred    )
    set -l bgbrgreen   (set_color --background $theme_brgreen  )
    set -l bgbryellow  (set_color --background $theme_bryellow )
    set -l bgbrblue    (set_color --background $theme_brblue   )
    set -l bgbrmagenta (set_color --background $theme_brmagenta)
    set -l bgbrcyan    (set_color --background $theme_brcyan   )
    set -l bgbrwhite   (set_color --background $theme_brwhite  )
    set -l orange      (set_color $theme_orange                )
    set -l bgorange    (set_color --background $theme_orange   )
    set -l brorange    (set_color $theme_brorange              )
    set -l bgbrorange  (set_color --background $theme_brorange )

    # COMPUTE PORMPT parts:

    set -l part_head "$__prompt_cache_head"
    set -l part_path "$reset"(_pwd_tilde_shrinkable 3)

    set -l part_errors (
        if test (count $lastpipestatus) -eq 1  # no pipe
            test $laststatus -eq 0
                or echo -n -- "$reset$reverse$fat($laststatus)$reset"
        else  # yes pipe
            set -l style "$reset$reverse$fat"

            if test $laststatus -ne 0
                echo -n -- "$style("(string join -- \| $lastpipestatus)
                test $lastpipestatus[-1] -eq 0
                    and echo -n -- "/$red$laststatus$style"
                echo -n -- ")$reset"

            else if test (math (string join '+' --  $lastpipestatus[1..-2])) -ne 0
                echo -n -- "$style("(string join -- \| $lastpipestatus[1..-2])"|"
                test "$lastpipestatus[-1]" -eq 0
                    or echo -n -- "$green"
                echo -n -- "$lastpipestatus[-1]$style)$reset"
            end
        end
    )

    # GIT PARTS
    set -l part_branch
    set -l part_git

    if _is_git_worktree

        # data:
        test (kvget is_parsed_stash $_kv_gitstate or echo "") = true
            or _parse_git_stash
        test (kvget is_parsed_porcelainv2 $_kv_gitstate or echo "") = true
        and test (kvget is_parsed_tags $_kv_gitstate or echo "") = true
            or _parse_porcelainv2 with-tags

        # branch status
        set -l name (kvget branch $_kv_gitstate)
        set -l ahead +(kvget ahead $_kv_gitstate)
        set -l behind -(kvget behind $_kv_gitstate)
        set part_branch (
            echo -n -- "$reset$fat"
            echo -n -- "($name"
            echo -n -- "$green$ahead"
            echo -n -- "$red$behind"
            echo -n -- "$reset$fat"') '
        )

        # more git info:
        set part_git (
            echo -n -- "("

            # submodule info
            echo -n -- "$reset$fat$reverse"(kvget changed_submods $_kv_gitstate)!"$reset"/
            echo -n -- (kvget submods $_kv_gitstate)"m "

            # stashes, untracked, ignored
            set -l sep ""
            echo -n "$reset$blue"(kvget stashes $_kv_gitstate
                and set sep " ")'*'
            echo -n "$reset$red"(kvget untracked $_kv_gitstate
                and set sep " ")"$fat"'?'
            echo -n "$reset$dim"(kvget ignored $_kv_gitstate
                and set sep " ")"$fat"'!'
            echo -n "$reset$sep"

            set -l wt_risk (kvget wt_risk $_kv_gitstate)
            switch "$wt_risk"
            case merge
                echo -n -- "$reset$fat$bgmagenta$white"
            case none
                echo -n -- "$reset$fat$bggreen$white"
            case low
                echo -n -- "$reset$fat$bgyellow$black"
            case medium
                echo -n -- "$reset$fat$bgorange$black"
            case high
                echo -n -- "$reset$fat$bgred$white"
            end
            # folder status: merge-state
            if test "$wt_risk" = merge
                echo -n -- (kvget unmerged_us $_kv_gitstate)U
                echo -n -- (kvget unmerged_both $_kv_gitstate)B
                echo -n -- (kvget unmerged_them $_kv_gitstate)T
            else
                # folder status un/staged files
                echo -n -- (kvget staged $_kv_gitstate; or echo 0)
                echo -n -- "|"
                echo -n -- (kvget unstaged $_kv_gitstate; or echo 0)
            end

            echo -n -- "$reset)"
        )
    else if _is_the_git_dir
        set part_branch "$reset$fat{.git}$reset "
    else
        set part_branch ""
    end

    # ASSEMBLE PROMPT:
    # ("$part_head" handles style reset and trailing space)
    echo -n -- "$part_branch$part_path $part_git$part_errors$part_head"
end
