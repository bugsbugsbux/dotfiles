#!/usr/bin/env bash
#XDG_RUNTIME_DIR # defined by pam_systemd as /run/user/(id --user)
#declare -x XDG_CACHE_HOME="$HOME/.cache"
#declare -x XDG_CONFIG_DIRS=/etc/xdg
#declare -x XDG_CONFIG_HOME="$HOME/.config"
#declare -x XDG_DATA_DIRS=/usr/local/share:/usr/share
#declare -x XDG_DATA_HOME="$HOME/.local/share"
#declare -x XDG_STATE_HOME="$HOME/.local/state"

_use_sway=true

[[ -f ~/.bashrc ]] && . ~/.bashrc
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then


    # TODO: replace ls|grep with globbing after setting extglob and nullglob options: /tmp/swaylog-+([0-9])

    if $_use_sway; then
        declare lastlog lastlognum nextlognum SWAYLOG
        lastlog="$(ls -1 /tmp | grep -E -x "swaylog-[0-9]+" | sort | tail -1)"
        lastlognum="${lastlog##*-}"
        nextlognum=$((lastlognum + 1))
        export SWAYLOG="/tmp/swaylog-$nextlognum"
        exec sway &> "${SWAYLOG-/tmp/swaylog-0}"
    fi

fi
