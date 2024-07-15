#!/usr/bin/env bash
#XDG_RUNTIME_DIR # defined by pam_systemd as /run/user/(id --user)
#declare -x XDG_CACHE_HOME="$HOME/.cache"
#declare -x XDG_CONFIG_DIRS=/etc/xdg
#declare -x XDG_CONFIG_HOME="$HOME/.config"
#declare -x XDG_DATA_DIRS=/usr/local/share:/usr/share
#declare -x XDG_DATA_HOME="$HOME/.local/share"
#declare -x XDG_STATE_HOME="$HOME/.local/state"

[[ -f ~/.bashrc ]] && . ~/.bashrc
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec sway &>/tmp/sway.out
fi
