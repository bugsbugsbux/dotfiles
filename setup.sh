#!/usr/bin/env bash

# tags: TODO, CHECK, NOTE, FIXME, DEBUG
# add your code in these places: <++>

#disable "arguments mentioned never passed" warning caused by my debug messages
# shellcheck disable=SC2120

# load utils
source ./setup-utils.sh

##################################################
# <++> optional: define function setup_home to set up HOME (apart from dotfiles) as you wish

setup_home() {
    debugmsg "### ${FUNCNAME[0]} $*"

    # dont do anything on termux
    isTermux && {
        infomsg "Skipping setup_home on platform termux"
        return $PATFORM_ERR
    }

    # create data folders
    mkdir_p ~/Data/{Documents,Videos,Music,Pictures}
    linkstall ~/{Data/,}Documents
    linkstall ~/{Data/,}Videos
    linkstall ~/{Data/,}Music
    linkstall ~/{Data/,}Pictures

    # create a downloads folder
    mkdir_p ~/Downloads

    # create a user bin/ folder
    mkdir_p ~/.local/bin

    # create a user-fonts folder
    local xdg_data_home
    xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    debugmsg "XDG_DATA_HOME='$xdg_data_home'"
    mkdir_p "$xdg_data_home"/fonts
}

##################################################
# <++> define your handlers

# A "handler" is a function invoked in a CLONE/TOPIC repo to install the files of this topic
# How to write a handler:
# 0. add the handler's name as value to a new key TOPIC in dictionary topic_handlers
# 1. checkout the files of the topic (using sparse-checkout patterns) using `checkoutFiles`
#   NOTE: the ptterns shall start with / (indicating the repository root)
#   NOTE: don't distinguish platforms yet
# 2. install these files to their correct locations using `linkstall` or `manual_install`
#   NOTE: distinguish platforms using isTermux, isNixOS
# 3. optional other actions related to given topic of files
#   NOTE: to create directories use `mkdir_p` (logs its activities)
# 4. logging would be nice (functions {log,err,warn,info,debug}mess)

handler_etc() {
    checkoutFiles /linux/etc

    if ! isTermux; then
        manual_install {linux,}/etc/environment
    fi
}

handler_shell() {
    checkoutFiles \
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
    checkoutFiles /linux/.config/nvim
    linkstall {linux,~}/.config/nvim
}

handler_sway() {
    checkoutFiles \
        /linux/.config/{sway,tofi} \
        /linux/.config/mako
    linkstall {linux,~}/.config/sway
    linkstall {linux,~}/.config/tofi
    #linkstall {linux,~}/.config/mako
}

handler_other() {
    checkoutFiles \
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


##################################################
# <++> assign handlers to a certain TOPIC repo
topic_handlers=(
    [etc]=handler_etc
    [shell]=handler_shell
    [nvim]=handler_nvim
    [sway]=handler_sway
    [other]=handler_other
)

##################################################
# run main function, unless this file is being sourced
(return &>/dev/null) || main "$@"

# vim: tw=0 cc=100
