#!/bin/sh

# current_os will be "Arch" on ArchLinux and "nixos" on NixOS
current_os="$(grep --max-count=1 --fixed-string DISTRIB_ID /etc/lsb-release | cut -d= -f2)"

if test "Arch" = "$current_os"; then

    # wallpaper (requires swaybg)
    swaymsg -q -- output '*' bg /usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill

    # fix x11/xorg (requires xhost;
    # archlinux installs xorg as dependency of xwayland)
    xhost local:

    # bluetooth
    # disable by default (requires bluez)
    bluetoothctl power off
    # activate systray icon (requires blueman)
    blueman-applet

elif test "nixos" = "$current_os"; then

    # wallpaper (requires swaybg)
    swaymsg -q -- output '*' bg /run/current-system/sw/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill

fi
