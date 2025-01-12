#!/bin/sh

# probably can't find this file on windows?

# tries to use the highlight script shipped with git

# nixos
if test -x /run/current-system/sw/share/git/contrib/diff-highlight/diff-highlight; then
    /run/current-system/sw/share/git/contrib/diff-highlight/diff-highlight | less

# other linux
elif test -x /usr/share/git/diff-highlight/diff-highlight; then
    /usr/share/git/diff-highlight/diff-highlight | less

# script not found. on nixos try: environment.pathsToLink =["/share/git"];
else
    less
fi
