set -l data (wget -q -O - http://raw.githubusercontent.com/wiki/alacritty/alacritty/Color-schemes.md)
count $data &>/dev/null
    or echo download failed... && exit 1

test -d ./themes_upstream
    or mkdir ./themes_upstream

set is_fenced false
set -g theme NONE
for line in $data
    if string match -q -- "```*" $line
        if test "$theme" = NONE
            # dont capture fenced stuff which is not a theme
            set is_fenced false
            continue
        end
        if $is_fenced
            # END FENCE
            set -g theme NONE
            set is_fenced false
        else
            # START FENCE
            set is_fenced true
        end

    else if set -l newtheme (string match -r -- "<summary>(?:<a .+?>)?(.+?(?=</))" $line)[2]
        set -g theme themes_upstream/(
            string replace --all " " "_" "$newtheme" \
            | string replace --all "/" "_" \
            | string collect
        ).yml
        echo -- "$theme"
    else
        if $is_fenced
            if test -f "$theme"
                echo -n >> "$theme"
            end
            echo -- "$line" >> "$theme"
        else
            # INGORED
            :
        end
    end
end
