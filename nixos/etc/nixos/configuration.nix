{ config, lib, pkgs, ... }:

let HOSTNAME = null;
    FIRST_INSTALL = null;
in {
    #
    # other config parts:
    #

    imports = [
        ./hardware-configuration.nix
    ];

    #
    # nix:
    #

    nix.settings.experimental-features = ["nix-command" "flakes"];

    nixpkgs.config.allowUnfree = true;

    #
    # system:
    #

    # leave this at **version of first install**
    system.stateVersion = FIRST_INSTALL; # DO NOT CHANGE THIS!

    # to upgrade nixos version: set a new global nixos channel like so:
    # sudo nix-channel --add https://nixos.org/channels/nixos-24.05 nixos
    system.autoUpgrade = {
        enable = false;
        allowReboot = false;
    };

    boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
    };

    boot.tmp.cleanOnBoot = true;    # clear /tmp on startup

    console.keyMap = "de-latin1";

    time.timeZone = "Europe/Berlin";

    # sync time with a timeserver
    services.chrony.enable = true;

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
        LC_ADDRESS          = "de_DE.UTF-8";
        LC_IDENTIFICATION   = "de_DE.UTF-8";
        LC_MEASUREMENT      = "de_DE.UTF-8";
        LC_MONETARY         = "de_DE.UTF-8";
        LC_NAME             = "de_DE.UTF-8";
        LC_NUMERIC          = "de_DE.UTF-8";
        LC_PAPER            = "de_DE.UTF-8";
        LC_TELEPHONE        = "de_DE.UTF-8";
        LC_TIME             = "de_DE.UTF-8";
    };

    networking = {
        hostName = HOSTNAME;

        firewall.enable = true;
        # open some ports:
        # firewall.allowedTCPPorts = [ ... ];
        # firewall.allowedUDPPorts = [ ... ];

        networkmanager.enable = true; # if true don't set wireless.enable=true
        wireless.enable = false;    # uses wpa_supplicant instead of networkmanager
    };

    hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;        # whether to start bluetooth immediately on boot
    };
    services.blueman.enable = true; # also provides blueman-applet

    fonts = let
        monego-font = pkgs.callPackage ./monego-font {};
    in {
        enableDefaultPackages = true; # has noto-fonts-color-emoji -> monochrome cannot be preferred
        packages = with pkgs; [
            noto-fonts
            noto-fonts-cjk
            noto-fonts-color-emoji      # already included when fonts.enableDefaultPackages=true
            noto-fonts-monochrome-emoji # monochrome emojis CANNOT take precedence over colored ones

            # windows fonts
            corefonts
            vistafonts

            # math fonts
            fira-math

            # custom fonts:
            monego-font
        ];
        fontconfig = {
            defaultFonts = {
                monospace = ["Monego" "Noto Sans Mono"];
                serif = ["Noto Serif"];
                sansSerif = ["Noto Sans"];

                # NOTE: fontconfig always prefers ANY color emoji font over ANY monochrome emoji
                # font; thus setting "Noto Emoji" (is monochrome) to be preferred, does not work!
                #emoji = ["Apple Color Emoji" "Noto Color Emoji"];
            };
        };
        fontDir.enable = true;
    };

    # sound via pipewire:
    services.pipewire = {
        enable = true;
        wireplumber.enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        jack.enable = false;
    };
    security.rtkit.enable = true;   # for pulseaudio

    # printing via cups
    services.printing.enable = true;

    # power management
    services.upower = {
        enable = true;
        percentageLow = 20;
        percentageCritical = 5;
        percentageAction = 2;
        # what to do? PowerOff, Hibernate, or HybridSleep (default)?
        #criticalPowerAction = "";
    };

    xdg.mime = {
        # see also: xdg.mime.{added,removed}Associations
        defaultApplications = {
            "application/pdf" = [ "org.gnome.Evince.desktop" "chromium-browser.desktop"];
        };
    };

    environment.variables = {
        EDITOR = "nvim";
    };

    #
    # specific programs:
    #

    # sway -- a wayland window manager:
    programs.sway = {
        enable = true;
        extraPackages = with pkgs; [ # added to environment.systemPackages
            acpi                    # battery and acpi info
            brightnessctl           # change monitor brightness
            foot                    # terminal
            foot.themes             # default themes for foot
            grim                    # grab images from wayland
            glib                    # provides `gsettings`,`gio`
            imagemagick             # used in my config for color picker tool
            jq                      # json parser,formatter
            libnotify               # provides notify-send
            swaynotificationcenter  # notifications
            slurp                   # select region from wayland
            swaybg                  # set background images
            tofi                    # opener
            wl-clipboard            # copy,paste on wayland

            gnome.adwaita-icon-theme # provides cursor styles

            # etc
            pulsemixer              # graphically adjust volume
        ];
        xwayland.enable = true;
        wrapperFeatures.gtk = true; # sets appropriate env-vars for GTK stuff
        extraSessionCommands = ''
        # fix: xdg-open
        systemctl --user import-environment PATH

        # fix: `amdgpu: amdgpu_cs_ctx_create2 failed. (-13)`
        if [[ "$(hostname)" == "tpe14gen3" ]]; then
            export WLR_RENDERER='' + "\"\${WLR_RENDERER:-vulkan}\";" + ''

        fi

        # once sway started we know, that truecolor support is possible, which it is
        # not in the tty, and thus this var is here and not in environment.variables
        export COLORTERM=truecolor

        # for the following variables see:
        # https://gitlab.freedesktop.org/wlroots/wlroots/-/blob/master/docs/env_vars.md?ref_type=heads
        # https://github.com/swaywm/sway/wiki/Running-programs-natively-under-wayland
        # https://wiki.nixos.org/wiki/Wayland

        # Gtk
        # CHECK: ensure this matches settings in sway config
        gsettings set org.gnome.desktop.interface cursor-theme Adwaita
        gsettings set org.gnome.desktop.interface cursor-size 28

        # Chromium/Electron
        export NIXOS_OZONE_WL=1

        # QT apps; require pkgs.qt5.qtwayland
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        # export QT_WAYLAND_FORCE_DPI=physical # use monitor's DPI instead of default (96)

        # Elementary/EFL
        export ECORE_EVAS_ENGINE=wayland_egl
        export ELM_ENGINE=wayland_egl
        export ELM_ACCEL=wayland_egl
        export ELM_DISPLAY=wl

        # SDL2 (SDL3+ uses wayland by default)
        export SDL_VIDEODRIVER=wayland

        # CLUTTER (discontinued):
        export CLUTTER_BACKEND=wayland

        # JAVA
        export _JAVA_AWT_WM_NONREPARENTING=1
        '';
    };
    xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
        ];
    };
    hardware.opengl.enable = true;

    programs.wireshark = {
        enable = true;
        package = pkgs.wireshark;
    };

    #
    # more global packages
    # these link some outputs to /run/current-system/sw/
    #

    environment.systemPackages = with pkgs; [
        bash-completion             # tab completion
        curl                        # make network requests
        git
            gh                      # access to github accouts
        htop                        # process monitor
        killall                     # kill processes by name
        neovim                      # editor
        nix-prefetch                # determine hash for FODs
        qemu_full                   # virtualization
        quickemu                    # preconfigured virtual machines
        tree                        # show nested folder structures
        wget                        # download files
        xdg-utils                   # open files appropriately

        qt5.full

        # apps:
        chromium                    # web browser
        evince                      # pdf viewer
        gedit                       # graphical file editor
        gnome.gnome-terminal        # my favorite terminal
        gnome.nautilus              # graphical file manager
        gnome.simple-scan           # scanner
        libreoffice-fresh           # document suite
        mpv                         # music,video player
        shotwell                    # image viewer
        snapshot                    # webcam
    ];

    environment.pathsToLink = [
        "/share/git"
        "/share/foot/themes"
    ];

    # userspace mounting, required for gio trash, gio mount, etc
    services.gvfs.enable = true;

    #
    # users:
    #

    users.users.auser = {
        initialPassword = "change_me_after_install";
        isNormalUser = true;
        extraGroups = [
            "wheel"
            "networkmanager"
            "wireshark"
        ];
        packages = with pkgs; [
            croc                    # securely send files
            fd                      # find alternative
            fish                    # like bash but more user friendly
            pandoc                  # markup converter
            ripgrep                 # fast file content searcher
            tmux                    # terminal multiplexer

            # for my neovim config:
                gnumake             # make for mason.nvim
                nodejs              # npm for treesitter.nvim
                gcc                 # compile c and cpp
                cargo               # compile rust
                unixtools.xxd       # vim's hexviewer for hex.nvim

            # apps:

            # games:
            zeroad
        ];
    };

    users.users.buser = {
        initialPassword = "change_me_after_install";
        isNormalUser = true;
        # extraGroups = [ "networkmanager" ];
        packages = with pkgs; [
        ];
    };

}
