#!/bin/sh

# don't assume order of startup/reload scripts

# current_os will be "Arch" on ArchLinux and "nixos" on NixOS
current_os="$(grep --max-count=1 --fixed-string DISTRIB_ID /etc/lsb-release | cut -d= -f2)"

if test "Arch" = "$current_os"; then

    # fix x11/xorg (requires xhost;
    # archlinux installs xorg as dependency of xwayland)
    xhost local:

    # bluetooth
    # disable by default (requires bluez)
    bluetoothctl power off
    # activate systray icon (requires blueman)
    blueman-applet

elif test "nixos" = "$current_os"; then

    :

fi
