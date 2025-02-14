#!/usr/bin/env bash

#disable the unwarranted warnings about unhandled cd/pushd/popd
# shellcheck disable=SC2164

# TODO:
# - echo does not have -- option; use printf instead
# - only warn of existing files when they are not links pointing to the correct location
# - manual_install:
#   + only inform user if file does not exist _or differs_
#   + disallow arguments of type directory (othewise can't diff them)
# - abort if no diffutils (diff) found

DOCSTRING='
This script shall "install" your dotfiles and set up HOME. In other words,
it shall place, usually as symbolic link, certain files and directories
in their correct locations (as specified in this script). This script shall
not handle "uninstalling" any files, however, it should handle encountering
already "installed" files gracefully.

Dotfiles are managed as follows:

+------+       Upstream repo. Used for syncing between different hosts.
|REMOTE|       Should be set with -r=someUrl
+------+
  ^            git clone --bare
  |
+----+         Bare clone of upstream repo. Used for
|BARE|         interacting with REMOTE and syncing repos under CLONES.
+----+
  ^            git clone && git sparse-checkout set
  |
  |            A clone of BARE using sparse-checkout to restrict the
  |            files to a certain topic. Used for working on these.
+------------+ Usually development happens on branch "dev"; then BARE
|CLONES/topic| is fetched, "dev" rebased onto it, "tmp" used to compose
+------------+ the history using cherry-picking, and finally "master"
  ^            pulls "tmp" using merge --no-ff and pushes it to BARE.
  |
  |            ln --symbolic --relative
+-------+
|dotfile|      A link to, or sometimes a copy of, the relevant
+-------+      version-controlled file in a repo in folder CLONES.

Usage: ./setup.sh [args]
Args:
-h --help       print this help-text and exit
-r= --remote=   where to clone BARE from
                default: PWD
-b= --bare=     intended location of BARE
                default: HOME/repos/dotfiles.git
-c= --clones=   intended location for CLONES of BARE
                default: HOME/.dot
-l= --logging-level=
                0 suppress non-fatal error messages (defined in this)
                1 only print errors
                2 print errors and warnings <-- DEFAULT
                3 print errors, warnings and infos
                4 print everything including debug infos
'

##### exit/return codes #####
GENERIC_ERR=1
INVOC_AS_ROOT_ERR=2     # this script must not be invoked as root
SCRIPT_ARG_ERR=3        # argument error when invoking this script
ARG_ERR=4               # argument error when invoking a function
DST_EXISTS_ERR=5        # trying to install to existing location
OPT_ERR=6               # invalid global config value
PATFORM_ERR=7           # action not possible on current platform
DEPENDENCY_ERR=8        # missing dependency

##### config and invocation of this script #####

REMOTE= # setup_dotfiles uses $PWD as default (see: setup_dotfiles)
BARE="$HOME/repos/dotfiles.git"
CLONES="$HOME/.dot"

LOGGING_LVL=2 # for meaning see DOCSTRING
isValidLoggingLevel() { [[ "$1" == [0-4] ]]; }

main() {
    if (( "$UID" == 0 )); then
        fatalError $INVOC_AS_ROOT_ERR "Must not run as root!"
    fi

    ! type -t git &>/dev/null && \
        fatalError $DEPENDENCY_ERR 'Missing dependency: git'
    ! type -t diff &>/dev/null && \
        fatalError $DEPENDENCY_ERR 'Missing dependency: diff (from diffutils package)'

    # handle arguments
    local currentOpt
    for arg; do
        if test -n "$currentOpt"; then
            case "$currentOpt" in
                -*) fatalError $SCRIPT_ARG_ERR "Missing option value!" ;;
                'remote') REMOTE="$arg"; currentOpt= ;;
                'bare') BARE="$arg"; currentOpt= ;;
                'clones') CLONES="$arg"; currentOpt= ;;
                'logging') LOGGING_LVL="$arg"; currentOpt=
                    isValidLoggingLevel "$LOGGING_LVL" || fatalError $SCRIPT_ARG_ERR "Invalid logging level"
                ;;
                *) fatalError $GENERIC_ERR "Logic error." ;;
            esac
        else
            case "$arg" in
                '-h'|'--help') echo -e "$DOCSTRING"; exit 0 ;;
                '-r'|'--remote') currentOpt=remote ;;
                -r=*|--remote=*) REMOTE="${arg#*=}";;
                '-b'|'--bare') currentOpt=bare ;;
                -b=*|--bare=*) BARE="${arg#*=}";;
                '-c'|'--clones') currentOpt=clones ;;
                -c=*|--clones=*) CLONES="${arg#*=}";;
                '-l'|'--logging-level') currentOpt=logging ;;
                -l=*|--logging-level=*) LOGGING_LVL="${arg#*=}"
                    isValidLoggingLevel "$LOGGING_LVL" || fatalError $SCRIPT_ARG_ERR "Invalid logging level"
                ;;
                *) fatalError $SCRIPT_ARG_ERR "Unknown argument '$arg'" ;;
            esac
        fi
    done

    # invoke subroutines
    setup_home
    setup_dotfiles
}

##### overrides: #####

# suppress pushd, popd output
pushd() { command pushd "$@"; } >/dev/null
# shellcheck disable=SC2120
popd() { command popd "$@"; } >/dev/null

##### helpers: #####

# always prints to stderr; prefer the logging functions instead
stderr() { echo -e "$*" >&2; }
# prints to stdout to avoid user-suppression via stderr-redirection
call_for_action() { echo -e "PLEASE: $*"; }
# various logging functions; always return true;
errmsg() { [[ "$LOGGING_LVL" -gt 0 ]] && stderr "Error: $*"; :; }
warnmsg() { [[ "$LOGGING_LVL" -gt 1 ]] && stderr "Warning: $*"; :; }
infomsg() { [[ "$LOGGING_LVL" -gt 2 ]] && stderr "Info: $*"; :; }
debugmsg() { [[ "$LOGGING_LVL" -gt 3 ]] && stderr "Debug: $*"; :; }

# usage: invocationError [exitCode] error message ...
fatalError() {
    local code=$GENERIC_ERR
    if [[ "$1" == [0-9]* ]]; then
        code="$1"
        shift
    fi
    stderr "FATAL ERROR! $*" >&2
    exit "$code"
}

isNixOS() {
    test -f /etc/lsb-release || return 1
    test "$(grep --max-count=1 --fixed-string DISTRIB_ID /etc/lsb-release | cut -d= -f2)" = "nixos"
}
isTermux() {
    test -d /data/data/com.termux/files
}

# check if $1 (or if omitted PWD) is a git repo
isRepo() {
    local d="${1:-.}" # . if $1 omitted
    local status
    if pushd "$d"; then
        status="$(git rev-parse --is-inside-work-tree 2>/dev/null)$(git rev-parse --is-inside-git-dir 2>/dev/null)"
        popd
        [[ "$status" == *true* ]]
        return #$?
    else
        return 1
    fi
}

hasUnstaged() {
    if ! git diff-files --quiet &>/dev/null; then # -> fails if has such
        infomsg "$PWD has unstaged files"
        return 0
    fi
    return 1
}
hasStaged() {
    if ! git diff-index --quiet --cached HEAD &>/dev/null; then # -> fails if has such
        infomsg "$PWD has staged files"
        return 0
    fi
    return 1
}
hasUntrackedUnignored() {
    # untracked, non-ignored files?
    if test -n "$(git ls-files --exclude-standard --others 2>/dev/null)"; then
        infomsg "$PWD has unracked, non-ignored files"
        return 0
    fi
    return 1
}

normalizePath() { realpath --canonicalize-missing --logical --physical "$1"; }
resolveLink() { readlink --canonicalize-missing "$1"; }

# installs $1 to location $2 by creating a symlink
# unless $2 already exists
linkstall() {
    if [[ "$#" -ne 2 ]]; then
        errmsg "expected exactly 2 args: src and dst"
        return $ARG_ERR
    fi
    local src dst
    src="${1/#'~'/$HOME}"
    dst="${2/#'~'/$HOME}"
    if [[ ! -e "$src" ]]; then
        errmsg "'$src' does not exist!"
        return $ARG_ERR
    fi

    if [[ -e "$dst" ]]; then
        if [[ -L "$dst" ]]; then # its a link:
            local normalized_src normalized_resolved_dst_link
            normalized_src="$(normalizePath "$src")"
            normalized_resolved_dst_link="$(resolveLink "$dst")"
            if [[ "$normalized_src" != "$normalized_resolved_dst_link" ]]; then
                # deliberately using warnmsg instead of errmsg here:
                warnmsg "Link '$dst' exists and points to '$normalized_resolved_dst_link' instead of '$normalized_src'"
                return $DST_EXISTS_ERR
            fi
            infomsg "Skipping to reinstall '$dst'"
            return 0
        elif [[ -f "$src" && -f "$dst" ]] || [[ -d "$src" && -d "$dst" ]]; then
            # diff can also compare folders
            if diff --recursive "$src" "$dst" &>/dev/null
            then warnmsg "'$dst' exists, but does not differ from '$src'"
            else errmsg "destination exists and differs from source; show with:\ndiff -r '$src' '$dst'"
            fi; return $DST_EXISTS_ERR
        fi
        errmsg "Cannot install '$src' to existing location '$dst'"
        return $DST_EXISTS_ERR
    fi

    mkdir -p "$(dirname "$dst")" # ensure target folder exists
    # --no-target-directory ensures src is not installed into dst but $(dirname dst)
    ln --symbolic --relative --no-target-directory "$src" "$dst" \
        && infomsg "Installed '$dst'" # || `ln` prints its own errors
}

# prompt user to manually install $1 to $2 if necessary
manual_install() {
    if [[ "$#" -ne 2 ]]; then
        errmsg "expected exactly 2 args: src and dst"
        return $ARG_ERR
    fi
    local src dst
    src="${1/#'~'/$HOME}"
    dst="${2/#'~'/$HOME}"
    if [[ ! -e "$src" ]]; then
        errmsg "'$src' does not exist"
        return $ARG_ERR
    fi

    local code="mkdir -p \"\$(dirname '$dst')\" && cp -LTR '$src' '$dst'"
    if [[ -e "$dst" ]]; then
        if [[ -f "$src" && -f "$dst" ]] \
        || [[ -d "$src" && -d "$dst" ]]; # diff can also compare folders:
        then
            if diff --recursive "$src" "$dst" &>/dev/null; then
                infomsg "Skipping to reinstall '$dst': doesn't differ from '$src'"
                return 0
            fi
        fi
        # shellcheck disable=SC2016
        call_for_action "$code # HOWEVER:\n\t#"\
            'location exists and differs from source; use `diff -r` to compare'
        return $DST_EXISTS_ERR
    fi
    call_for_action "$code"
}

##### dotfiles #####

setup_dotfiles() {
    # create required folders
    mkdir -p ~/.config "$CLONES" "$(dirname "$BARE")"

    # create bare clone if necessary
    if pushd "$BARE"; then
        if ! isRepo "$BARE" || [ "$(git rev-parse --is-bare-repository)" = false ]; then
            errmsg "'$BARE' is not a bare repo"
            return $OPT_ERR
        fi

        # warn of local origin remote
        local upstream
        upstream="$(git remote get-url origin)"
        if  [[ "$upstream" != http://*
            && "$upstream" != https://*
            && "$upstream" != git://*
            && "$upstream" != ssh://*
            && "$upstream" != ftp://*
            && "$upstream" != ftps://*
            && "$upstream" != *@*:/*
            && "$upstream" != *@*:~/*
        ]]; then
            warnmsg "BARE's origin remote seems to be local: '$upstream'"
        fi

        popd
    else
        # REMOTE defaults to $PWD
        if test -z "$REMOTE"; then
            if ! isRepo "$PWD"; then
                fatalError $OPT_ERR "'$REMOTE' is not a git repository"
            fi
            REMOTE="$PWD"
        fi
        # warn of local origin
        if test -e "$REMOTE"; then
            warnmsg "BARE's origin remote will point to a local repository\n\t" \
                "to change this use: git remote set-url origin URL"
        fi

        git clone --quiet --bare --no-local "$REMOTE" "$BARE" || {
            errmsg "Could not create the bare clone '$BARE' of '$REMOTE'"
            return 1 # TODO: global exit code
        }
    fi

    # create sparse clones and install their files
    pushd "$CLONES" && {
        cloneAndHandle {,handler_}etc
        cloneAndHandle {,handler_}shell
        cloneAndHandle {,handler_}nvim
        cloneAndHandle {,handler_}sway
        cloneAndHandle {,handler_}other
    popd; }
}

# $1=name
# $2=handler
cloneAndHandle() {
    if [[ "$#" -ne 2 ]]; then
        errmsg "expected exactly 2 args: name and handler"
        return $ARG_ERR
    fi
    local name="$1"
    local handler="$2"
    declare -F "$handler" &>/dev/null || {
        errmsg "Unknown handler '$handler'"
        return $ARG_ERR
    }

    git clone --quiet "$BARE" "$name"
    pushd "$name" && {
        if isRepo; then
            # ensure has dev branch
            git branch dev &>/dev/null
            # try to switch to branch dev
            if ! hasUntrackedUnignored && ! hasUnstaged && ! hasStaged; then
                git co --quiet -b dev &>/dev/null
            # else # no need to inform user here
            fi
            # reset sparse checkout spec
            git sparse-checkout disable
            # run handler
            $handler
        else
            errmsg "Failed to create clone '$BARE/$name' [exists, not a repo]"
        fi
    popd; }
}

##### setup home directory #####

setup_home() {

    # dont do anything on termux
    isTermux && return $PATFORM_ERR

    # create data folders
    mkdir -p ~/Data/{Documents,Videos,Music,Pictures}
    linkstall ~/{Data/,}Documents
    linkstall ~/{Data/,}Videos
    linkstall ~/{Data/,}Music
    linkstall ~/{Data/,}Pictures

    # create a downloads folder
    mkdir -p ~/Downloads

    # create a user bin/ folder
    mkdir -p ~/.local/bin

    # create a user-fonts folder
    local xdg_data_home
    xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    infomsg "Using '$xdg_data_home' as XDG_DATA_HOME"
    mkdir -p "$xdg_data_home"/fonts

}

##### define your dotfile installer handlers
# 0. dont forget to register handler with setup_dotfiles
# 1. set the sparse checkout spec
#   NOTE: sparse patterns shall start with /
# 2. install the files to their correct locations

handler_etc() {
    git sparse-checkout set --no-cone /setup.sh \
        /linux/etc

    if isNixOS; then
        manual_install {linux,}/etc/nixos
        # put link to nixos subfolder of repo into HOME
        linkstall linux/etc/nixos ~/nixos
    elif ! isTermux; then
        manual_install {linux,}/etc/environment
    fi
}

handler_shell() {
    git sparse-checkout set --no-cone /setup.sh \
        /linux/etc/profile \
        /linux/{.{bash,input}rc,.{,bash_}profile,.bash_{login,logout,aliases}} \
        /linux/.config/fish

    linkstall {linux,~}/.inputrc
    # bash
    linkstall {linux,~}/.bashrc
    linkstall {linux,~}/.bash_aliases
    # read when invoked as login shell
        # manual_install {linux,}/etc/profile
        # linkstall {linux,~}/.profile
        # linkstall {linux,~}/.bash_login
        linkstall {linux,~}/.bash_profile
    # read when exiting a login shell (using exit or when interactive)
        # linkstall {linux,~}/.bash_logout
    # fish
    linkstall {linux,~}/.config/fish
}

handler_nvim() {
    git sparse-checkout set --no-cone /setup.sh \
        /linux/.config/nvim
    linkstall {linux,~}/.config/nvim
}

handler_sway() {
    git sparse-checkout set --no-cone /setup.sh \
        /linux/.config/{sway,tofi} \
        /linux/.config/mako
    linkstall {linux,~}/.config/sway
    linkstall {linux,~}/.config/tofi
    #linkstall {linux,~}/.config/mako
}

handler_other() {
    git sparse-checkout set --no-cone /setup.sh \
        /linux/.npmrc \
        /linux/.config/{alacritty,foot,wezterm} \
        /linux/.config/git \
        /linux/.config/tmux \
        /linux/.config/wireplumber \
        /linux/.config/chromium-flags.conf
    # terminals
        linkstall {linux,~}/.config/alacritty
        linkstall {linux,~}/.config/foot
        linkstall {linux,~}/.config/wezterm
    linkstall {linux,~}/.npmrc
    linkstall {linux,~}/.config/git
    linkstall {linux,~}/.config/tmux
    linkstall {linux,~}/.config/wireplumber
    linkstall {linux,~}/.config/chromium-flags.conf
}

##### run this script: #####
main "$@"
