#!/bin/sh

# don't assume order of startup/reload scripts

# current_os will be "Arch" on ArchLinux and "nixos" on NixOS
current_os="$(grep --max-count=1 --fixed-string DISTRIB_ID /etc/lsb-release | cut -d= -f2)"

if test "Arch" = "$current_os"; then

    # wallpaper (requires swaybg)
    swaymsg -q -- output '*' bg /usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill

elif test "nixos" = "$current_os"; then

    # wallpaper (requires swaybg)
    swaymsg -q -- output '*' bg /run/current-system/sw/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill

fi
