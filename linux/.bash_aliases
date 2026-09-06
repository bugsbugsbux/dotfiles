alias ls='ls --color=auto'
alias la='ls --color=auto -A'
alias ll='ls --color=auto -lhA'
alias l='ls --color=auto -1'

alias vi=vim
alias vim=nvim

alias py='PYTHONASYNCIODEBUG=1 PYTHONTRACEMALLOC=1 python'

alias del='gio trash'

alias open='xdg-open'

alias untar='tar xaf' # auto detects compression

alias wscan='nmcli device wifi list --rescan yes'
alias wcon='nmcli device wifi connect'
alias woff='nmcli radio wifi off'
alias won='nmcli radio wifi on'

alias p1='ping -c4 1.1.1.1'
alias p8='ping -c4 8.8.8.8'
alias p138='ping -c4 10.0.0.138'
alias p192='ping -c4 192.168.0.1'

alias hl='grep --color --null-data'
