## different command ##
alias vim='echo "use neovim (nvim)"; false'
alias ag='echo "use ripgrep (rg)"; false'
alias find='echo "use fd"; false'
#alias cat='bat'
## orig command ##
#alias realcat='/usr/bin/cat'

## convenience ##
alias ls='ls --color=auto'
alias la='ls --color=auto -A'
alias ll='ls --color=auto -lhA'
alias l='ls --color=auto -1'
alias t='task'
alias o='xdg-open'
alias trm='gio trash'
alias e='nvim'
alias gmnt-dev='gio mount -m -d'
alias gmnt-able='gio mount -li | less'

alias py='PYTHONASYNCIODEBUG=1 PYTHONTRACEMALLOC=1 python'
alias trash='gio trash'
alias untar='tar xaf'  # auto detect compression

## behavioural change ##
alias yay='yay --aur'
alias tach='tmux attach-session -t'
