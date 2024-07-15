# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ===== ask to start fish =====
if [[ $(tty) != /dev/tty1 ]]; then
    if which fish &>/dev/null; then
        read -p "start fish? [y/N] " fish
        case $fish in
            y*)
                exec fish;;
        esac
    fi
fi

# ===== info in new windows =====
# show tmux sessions
which tmux &>/dev/null && tmux ls 2>/dev/null
# show task
which task &>/dev/null && task next

# ===== prompt =====
PS1='$(bash ~/.prompt $? )'
#PS1='($?)$ '

# ===== history =====
# unlimited history
HISTSIZE=-1
HISTFILESIZE=-1
# immediately write history # this doesn't destroy local hist
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# ===== behaviour =====
set -o vi # not needed if set in inputrc
# bash aliases
test -f $HOME/.bash_aliases && source ~/.bash_aliases
# recommendations if command not found
test -f /usr/share/doc/pkgfile/command-not-found.bash && \
    source /usr/share/doc/pkgfile/command-not-found.bash
# local bin directory
PATH+=":$HOME/.local/bin"


# ===== vars =====
##XDG_RUNTIME_DIR # defined by pam_systemd /run/user/(id --user)
if [[ ! -v XDG_CACHE_HOME  ]]; then XDG_CACHE_HOME=${HOME}/.cache ; fi
if [[ ! -v XDG_CONFIG_DIRS ]]; then XDG_CONFIG_DIRS=/etc/xdg ; fi
if [[ ! -v XDG_CONFIG_HOME ]]; then XDG_CONFIG_HOME=${HOME}/.config ; fi
if [[ ! -v XDG_DATA_DIRS   ]]; then XDG_DATA_DIRS=/usr/local/share:/usr/share ; fi
if [[ ! -v XDG_DATA_HOME   ]]; then XDG_DATA_HOME=${HOME}/.local/share ; fi
if [[ ! -v XDG_STATE_HOME  ]]; then XDG_STATE_HOME=${HOME}/.local/state ; fi
export XDG_CACHE_HOME XDG_CONFIG_DIRS XDG_CONFIG_HOME XDG_DATA_DIRS XDG_DATA_HOME XDG_STATE_HOME
export EDITOR=nvim
#export PAGER=less
export DIFFPROG="nvim -d"
# language:
#export LANG=en_US.UTF-8 # equals LC_ALL if thats set
##export LC_MESSAGES="de_DE.UTF-8"
#export LC_MESSAGES="en_US.UTF-8"
#export LC_CTYPE="de_DE.UTF-8"
#export LC_NUMERIC="de_DE.UTF-8"
#export LC_TIME="de_DE.UTF-8"
#export LC_COLLATE="de_DE.UTF-8"
#export LC_MONETARY="de_DE.UTF-8"
#export LC_PAPER="de_DE.UTF-8"
#export LC_NAME="de_DE.UTF-8"
#export LC_ADDRESS="de_DE.UTF-8"
#export LC_TELEPHONE="de_DE.UTF-8"
#export LC_MEASUREMENT="de_DE.UTF-8"
#export LC_IDENTIFICATION="de_DE.UTF-8"

# ===== completions =====
source /usr/share/bash-completion/completions/*
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    source /usr/share/bash-completion/bash_completion
# doas
complete -cf doas
# git
test -f /usr/share/git/completion/git-completion.bash && \
    source /usr/share/git/completion/git-completion.bash
# gh
which gh &>/dev/null && eval "$(gh completion -s bash)"
# fzf
test -f /usr/share/fzf/completion.bash && source /usr/share/fzf/completion.bash
# tmux completion (https://github.com/imomaliev/tmux-bash-completion.git)
test -f $HOME/repos/installed/tmux-bash-completion/completions/tmux && \
    source ~/repos/installed/tmux-bash-completion/completions/tmux

# ===== cmd config =====
# fzf
which fzf &>/dev/null && source /usr/share/fzf/key-bindings.bash
# flutter
test -d $HOME/repos/installed/flutter && PATH+=":$HOME/repos/installed/flutter/bin"
test -d $HOME/.pub-cache/bin && PATH+=":$HOME/.pub-cache/bin"
# rust
test -d "$HOME/.cargo/bin" && PATH+=":$HOME/.cargo/bin"
