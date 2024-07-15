function fish_greeting
    # user messages:
    set -qU messages; or set -U messages
    echo -n (set_color green)
    if test -n "$messages"
        echo User-messages:
        set -l count 0
        for message in $messages
            set count (math "$count + 1")
            echo -- "$count": $message
        end
        echo ----------
    else
        set --universal messages
    end


    # package tasks
    echo -n (set_color red)
    ## notify of .pacnew and .pacsave files
    find /etc -regextype posix-extended -regex ".+\.pac(new|save)" 2> /dev/null
    ## notify of big cache
    if test -d /var/cache/pacman/pkg
        echo -n "Current pacman cache is: "(
            du -sh -t 10G /var/cache/pacman/pkg | cut -f1
        )' Use `pacman -Sc; paru --clean` to clean it.'\n
    end
    echo -n (set_color normal)

    # notify of littered $HOME/Downloads
    echo -n (set_color red)
    if test -d ~/Downloads
        set -l amount (count (ls -A ~/Downloads))
        and echo (set_color -o)"~/Downloads littered with $amount element/s!"
    end
    echo -n (set_color normal)

    # notify of unattached tmux sessions
    echo -n (set_color red)
    set -l unattached (tmux ls -f '#{?session_attached,,not}' -F '#S')
    if count $unattached &>/dev/null
        echo Unattached tmux session names: (string join -- ', ' $unattached)
    end
    echo -n (set_color normal)


end
