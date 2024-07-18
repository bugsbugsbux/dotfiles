# don't do anything when not interactive
[[ $- != *i* ]] && return

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
