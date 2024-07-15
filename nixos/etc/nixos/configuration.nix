{ config, lib, pkgs, ... }:

let HOSTNAME = "tpe14g3";
    FIRST_INSTALL = "23.11";
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

    console.keyMap = "de-latin1-nodeadkeys";

    time.timeZone = "Europe/Berlin";

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

    fonts = let
        monego-font = pkgs.callPackage ./monego-font {};
    in {
        enableDefaultPackages = true;
        packages = with pkgs; [
            # custom fonts:
            monego-font
        ];
        fontconfig = {
            defaultFonts = {
                monospace = ["Monego"];
            };
        };
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
            jq                      # json parser,formatter
            libnotify               # provides notify-send
            mako                    # notifications
            slurp                   # select region from wayland
            swaybg                  # set background images
            tofi                    # opener
            wl-clipboard            # copy,paste on wayland

            # etc
            pulsemixer              # graphically adjust volume
        ];
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

    #
    # more global packages
    # these link some outputs to /run/current-system/sw/
    #

    environment.systemPackages = with pkgs; [
        bash-completion             # tab completion
        curl                        # make network requests
        git
            gh                      # access to github accouts
        neovim                      # editor
        nix-prefetch                # determine hash for FODs
        tree                        # show nested folder structures
        wget                        # download files
        xdg-utils                   # open files appropriately

        # # apps:
        chromium                    # web browser
    ];

    environment.pathsToLink = [
        "/share/foot/themes"
    ];

    #
    # users:
    #

    users.users.auser = {
        initialPassword = "change_me_after_install";
        isNormalUser = true;
        extraGroups = [
            "wheel"
            "networkmanager"
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
