#!/usr/bin/env bash

# tags: TODO, CHECK, NOTE, FIXME, DEBUG

# structure of this script:
# 1. error codes
# 2. docstring (--help)
# 3. cloneAndHandle preceded by its dependencies
# 4. setup_dotfiles preceded by its dependencies
# 5. main preceded by its dependencies
# 6. functions only used in handlers each preceded by their dependencies

#disable the unwarranted warnings about unhandled cd/pushd/popd
# shellcheck disable=SC2164
#disable "arguments mentioned never passed" warning caused by my debug messages
# shellcheck disable=SC2120

GENERIC_ERR=1
INVOC_AS_ROOT_ERR=2     # this script must not be invoked as root
SCRIPT_ARG_ERR=3        # argument error when invoking this script
ARG_ERR=4               # argument error when invoking a function
DST_EXISTS_ERR=5        # trying to install to existing location
OPT_ERR=6               # invalid global config value
PATFORM_ERR=7           # action not possible on current platform
DEPENDENCY_ERR=8        # missing dependency

DOCSTRING=\
'Usage: ./setup.sh [opts]

This script shall "install" your dotfiles and set up HOME. In other words,
it shall place, usually as symbolic link, certain files and directories
in their correct locations (as specified in this script). This script shall
not handle "uninstalling" any files, however, it should handle encountering
already "installed" files gracefully.

Concept:
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
|CLONES/TOPIC| is fetched, "dev" rebased onto it, "tmp" used to compose
+------------+ the history using cherry-picking, and finally "master"
  ^            pulls "tmp" using merge --no-ff and pushes it to BARE.
  |
  |            ln --symbolic --relative
+-------+
|dotfile|      A link to, or sometimes a copy of, the relevant
+-------+      version-controlled file in a repo in folder CLONES.

Options:
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

REMOTE= # setup_dotfiles uses $PWD as default (see: setup_dotfiles)
BARE="$HOME/repos/dotfiles.git"
CLONES="$HOME/.dot"
LOGGING_LVL=2 # for meaning see DOCSTRING

isValidLoggingLevel() { [[ "$1" == [0-4] ]]; }

# check whether logging level is _at least_ ...
IF_LVL_ERR()   { [[ "$LOGGING_LVL" -gt 0 ]]; }
IF_LVL_WARN()  { [[ "$LOGGING_LVL" -gt 1 ]]; }
IF_LVL_INFO()  { [[ "$LOGGING_LVL" -gt 2 ]]; }
IF_LVL_DEBUG() { [[ "$LOGGING_LVL" -gt 3 ]]; }

# print to stderr interpreting backslashes; always returns true, doesn't forward options
stderr() { echo -e "$*" >&2; :; }

# args: [opt|--] message ...
logmsg() {
    case "$1" in
        '--') shift;;
        '-e'|'--error') ! IF_LVL_ERR && return 0; shift;;
        '-w'|'--warn')  ! IF_LVL_WARN && return 0; shift;;
        '-i'|'--info')  ! IF_LVL_INFO && return 0; shift;;
        '-d'|'--debug') ! IF_LVL_DEBUG && return 0; shift;;
    esac
    stderr "$*"
}
# wrappers:
errmsg()  { logmsg -e "Error: $*"; }
warnmsg() { logmsg -w "Warn: $*"; }
infomsg() { logmsg -i "Info: $*"; }
debugmsg(){ logmsg -d "Debug: $*"; }

# args: [exitCode] error message ...
fatalError() {
    debugmsg "### ${FUNCNAME[0]} $*"
    local code=$GENERIC_ERR
    if [[ "$1" == [0-9]* ]]; then
        code="$1"
        shift
    fi
    stderr "FATAL ERROR! $*" >&2
    exit "$code"
}


# args: path ...
# `mkdir -p` but with logging
mkdir_p() {
    debugmsg "### ${FUNCNAME[0]} $*"
    for path; do
        path="${path/#'~'/$HOME}" # expand literal tilde
        test -d "$path" && continue
        if mkdir -p "$path"; then
            infomsg "created '$path' (and possibly missing parents)"
        fi
    done
}

# `pushd` with logging
pushd() {
    if command pushd "$@" &>/dev/null; then
        IF_LVL_DEBUG && debugmsg "cd $PWD"
        return 0
    else
        IF_LVL_DEBUG && debugmsg "couldn't cd to $*";
        return 1
    fi
}

# `popd` with logging
popd() {
    if command popd $* &>/dev/null; then
        IF_LVL_DEBUG && debugmsg "cd back to $PWD"
        return 0
    else
        IF_LVL_DEBUG && debugmsg "couldn't cd back to $OLDPWD"
        return 1
    fi
}

# args: [path]
# check if $1 (or if omitted PWD) is a git repo
isRepo() {
    debugmsg "### ${FUNCNAME[0]} $*"
    local d="${1:-.}" # . if $1 omitted
    d="${d/#'~'/$HOME}" # expand literal tilde
    local status
    if pushd "$d"; then
        status="$(
            git rev-parse --is-inside-work-tree 2>/dev/null
        )$(
            git rev-parse --is-inside-git-dir 2>/dev/null
        )"
        popd
        [[ "$status" == *true* ]]
        return #$?
    else
        return 1
    fi
}

# target repo is PWD
hasUntrackedUnignored() {
    debugmsg "### ${FUNCNAME[0]} $*"
    # this git command compares HEAD to the index and fails if they differ
    # `ls-files` usually lists all tracked files, but
    # `--other` specifies to only show untracked files
    # `--exclude-standard` except those ignored with gitignore
    if test -n "$(git ls-files --others --exclude-standard 2>/dev/null)"; then
        infomsg "$PWD has untracked, non-ignored files"
        return 0
    fi
    return 1
}

# target repo is PWD
hasUnstaged() {
    debugmsg "### ${FUNCNAME[0]} $*"
    # this git command compares index and workingtree and fails if they differ
    if ! git diff-files --quiet &>/dev/null; then
        infomsg "$PWD has unstaged files"
        return 0
    fi
    return 1
}

# target repo is PWD
hasStaged() {
    debugmsg "### ${FUNCNAME[0]} $*"
    # this git command compares HEAD to the index and fails if they differ
    if ! git diff-index --quiet --cached HEAD &>/dev/null; then
        infomsg "$PWD has staged files"
        return 0
    fi
    return 1
}

# args: name handler
# - name: name of folder in $CLONES
# - handler: name of the function which defines the sparse checkout spec and installs the files
cloneAndHandle() {
    debugmsg "### ${FUNCNAME[0]} $*"
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

    ! test -e "$name" && git clone --quiet "$BARE" "$name" 2>/dev/null
    if pushd "$name"; then
        if isRepo; then
            # ensure has dev branch
            git branch dev &>/dev/null
            # try to switch to branch dev
            if ! hasUntrackedUnignored && ! hasUnstaged && ! hasStaged; then
                git checkout --quiet -b dev &>/dev/null
            # else # no need to inform user here
            fi
            # reset sparse checkout spec
            git sparse-checkout disable
            # run handler
            $handler
        else
            errmsg "Failed to create or reuse clone '$BARE/$name' [directory, not a repo]"
            return $OPT_ERR
        fi
        popd
    else
        errmsg "Failed to create clone '$BARE/$name'"
        return $OPT_ERR # admittedly could also be network issue
    fi
}

# maps name of topic (used as folder name) to function name of handler which is called in the clone
# to install the checked out files to their correct locations
declare -A topic_handlers

setup_dotfiles() {
    debugmsg "### ${FUNCNAME[0]} $*"
    # create required folders
    mkdir_p ~/.config "$CLONES" "$(dirname "$BARE")"

    # create bare clone if necessary
    if pushd "$BARE"; then
        if isRepo && [ "$(git rev-parse --is-bare-repository)" = true ]; then
            # BARE must not have any worktrees, otherwise one cannot push to it, which is the whole
            # point. sadly this is not already checked by --is-bare-repository
            git worktree prune --no-verbose
            local wtlist
            wtlist="$(git rev-parse --git-dir)"/worktrees
            if [[ -d "$wtlist" && $(ls -1 "$wtlist" | wc -l) -gt 0 ]]; then
                errmsg "failed to reuse folder '$BARE' as BARE: has worktrees"
                return $OPT_ERR
            else
                warnmsg "Reusing existing BARE ('$BARE'), thus ignoring any --remote argument"
            fi
        else
            errmsg "failed to reuse folder '$BARE' as BARE: not a repo or not bare"
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

        # warn if upstream differs from REMOTE
        if [[ -n "$REMOTE" && "$upstream" != "$REMOTE" ]]; then
            warnmsg "Using existing BARE ($BARE); however it's upstream ($upstream) differs"
            logmsg -w "\tfrom the requested one ($REMOTE)"
        fi

        popd
    else
        # REMOTE defaults to $PWD
        if test -z "$REMOTE"; then
            if ! isRepo "$PWD"; then
                fatalError $OPT_ERR "failed to fall back to '$PWD' as REMOTE: not a repo"
            fi
            warnmsg "falling back to current working directory ($PWD) as REMOTE"
            REMOTE="$PWD"
        fi
        # warn of local origin
        if test -e "$REMOTE"; then
            warnmsg "BARE's origin remote will point to a local repository\n\t" \
                "to change this use: git remote set-url origin URL"
        fi

        if ! test -e "$BARE"; then
            git clone --quiet --bare --no-local "$REMOTE" "$BARE" 2>/dev/null || {
                errmsg "Could not create the bare clone '$BARE' of '$REMOTE'"
                return $OPT_ERR # admittedly could also be network issue
            }
        elif ! isRepo "$BARE"; then
            errmsg "Failed to reuse '$BARE' as BARE"
            return $OPT_ERR
        fi
    fi

    # create sparse clones and install their files
    pushd "$CLONES" && {
        local found_handlers=false
        for topic in "${!topic_handlers[@]}"; do
            [[ "$topic" == [[:digit:]]* ]] && { # digit followed by anything
                errmsg "Skipping topic due to invalid name: $topic"
                continue
            }
            found_handlers=true
            local handler="${topic_handlers[$topic]}"

            cloneAndHandle "$topic" "$handler"

        done
        if ! $found_handlers; then
            warnmsg "found no handlers"
        fi
    popd; }
}

main() {
    # cannot log here since logging level still unknown

    if (( "$UID" == 0 )); then
        fatalError $INVOC_AS_ROOT_ERR "Must not run as root!"
    fi

    # check dependencies
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
                    isValidLoggingLevel "$LOGGING_LVL" \
                        || fatalError $SCRIPT_ARG_ERR "Invalid logging level"
                ;;
                *) fatalError $GENERIC_ERR "unreachable" ;;
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
                    isValidLoggingLevel "$LOGGING_LVL" \
                        || fatalError $SCRIPT_ARG_ERR "Invalid logging level"
                ;;
                *) fatalError $SCRIPT_ARG_ERR "Unknown argument '$arg'" ;;
            esac
        fi
    done

    # invoke subroutines
    if [[ "$(type -t setup_home)" != "function" ]]; then
        warnmsg "no function 'setup_home' found"
    else
        setup_home
    fi
    setup_dotfiles # reuse exit code as script's exit status
}

# args: path
normalizePath() {
    debugmsg "### ${FUNCNAME[0]} $* #:"
    local result
    result="$(realpath --canonicalize-missing --logical --physical "$1")"
    logmsg -d "\t$result"
    printf '%s\n' "$result"
}

# args: path
resolveLink() {
    debugmsg "### ${FUNCNAME[0]} $* #:"
    local result
    result="$(readlink --canonicalize-missing "$1")"
    logmsg -d "\t$result"
    printf '%s\n' "$result"
}

# args: src dst
# installs $1 to location $2 by creating a symlink
# unless $2 already exists
linkstall() {
    debugmsg "### ${FUNCNAME[0]} $*"
    if [[ "$#" -ne 2 ]]; then
        errmsg "expected exactly 2 args: src and dst"
        return $ARG_ERR
    fi
    local src dst
    src="${1/#'~'/$HOME}" # expand literal tilde
    dst="${2/#'~'/$HOME}" # expand literal tilde
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
            then warnmsg "'$dst' exists (not a link), but does not differ from '$src'"
            else
                errmsg "destination exists and differs from source; show with:"
                logmsg -e "\tdiff -r '$src' '$dst'"
            fi; return $DST_EXISTS_ERR
        fi
        errmsg "Cannot install '$src' to existing location '$dst'"
        return $DST_EXISTS_ERR
    fi

    mkdir_p "$(dirname "$dst")" # ensure target folder exists
    # --no-target-directory ensures src is not installed into dst but $(dirname dst)
    ln --symbolic --relative --no-target-directory "$src" "$dst" \
        && infomsg "Installed '$dst'" # || `ln` prints its own errors
}

# instruct the user to do something manually
# prints to stdout to avoid user-suppression via stderr-redirection
call_for_action() { echo -e "PLEASE: $*"; }

# args: src dst
# prompt user to manually install $1 to $2 if necessary
manual_install() {
    debugmsg "### ${FUNCNAME[0]} $*"
    if [[ "$#" -ne 2 ]]; then
        errmsg "expected exactly 2 args: src and dst"
        return $ARG_ERR
    fi
    local src dst
    src="${1/#'~'/$HOME}" # expand literal tilde
    dst="${2/#'~'/$HOME}" # expand literal tilde
    if [[ ! -e "$src" ]]; then
        errmsg "'$src' does not exist"
        return $ARG_ERR
    fi

    local code="mkdir -p \"\$(dirname '$dst')\" && cp -LTR '$PWD/$src' '$dst'"
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
            'location exists and differs from source; compare with \n\t#'\
            "diff -r '$PWD/$src' '$dst'"
        return $DST_EXISTS_ERR
    fi
    call_for_action "$code"
}

# args: [pattern ...]
# sparse-checkout with --no-cone, including /setup{,-utils}.sh and warning about certain patterns
checkoutFiles() {
    debugmsg "### ${FUNCNAME[0]} $*"
    for pat; do
        [[ "$pat" != /* ]] && warnmsg "sparse-checkout pattern '$pat' doesn't start with slash"
    done
    git sparse-checkout set --no-cone /setup.sh /setup-utils.sh "$@"
}

isNixOS() {
    debugmsg "### ${FUNCNAME[0]} $*"
    test -f /etc/lsb-release || return 1
    test "$(grep --max-count=1 --fixed-string DISTRIB_ID /etc/lsb-release | cut -d= -f2)" = "nixos"
}

isTermux() {
    debugmsg "### ${FUNCNAME[0]} $*"
    test -d /data/data/com.termux/files
}

# vim: tw=0 cc=100
