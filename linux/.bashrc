# don't do anything when not interactive
[[ $- != *i* ]] && return

#suppress failures if my color util is not installed
type -t color &>/dev/null || color() {
    echo -n ''
}

test -e ~/.bash_aliases && source ~/.bash_aliases

# unlimited history
HISTSIZE=-1
HISTFILESIZE=-1
# immediately write history; doesn't destroy local history
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# \w is $PWD with $HOME as ~
PS1='\w ($?)> '

set -o vi       # not needed if set in ~/.inputrc

greeter() {
    # # packages
    # echo -en $(color red)
    # ## notify of .pacnew and .pacsave files
    # find /etc -regextype posix-extended -regex ".+\.pac(new|save)" 2> /dev/null
    # ## notify of big cache
    # if test -d /var/cache/pacman/pkg; then
    #     echo -e "Current pacman cache is:" "$(
    #         du -sh -t 10G /var/cache/pacman/pkg | cut -f1
    #     )" 'Use `pacman -Sc; paru --clean` to clean it.'
    # fi
    # echo -en $(color reset)

    # notify of littered $HOME/Downloads
    echo -en $(color red)
    if test -d ~/Downloads; then
        local amount=$(ls -A1 ~/Downloads | wc -l)
        if ((amount > 0)); then
            echo -e $(color fat)"~/Downloads littered with $amount element/s!"
        fi
    fi
    echo -en $(color reset)

    # notify of unattached tmux sessions
    echo -en $(color red)
    local unattached
    readarray -t unattached < <(tmux ls -f '#{?session_attached,,not}' -F '#S' 2>/dev/null)
    if test -n "${unattached[*]}"; then
        echo "Unattached tmux session names: $(printf '%s, ' "${unattached[@]}" | head -c -2)"
    fi
    echo -en $(color reset)

}
greeter
