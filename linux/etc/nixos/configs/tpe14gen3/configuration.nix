# TAGS: TODO, NOTE, CHECK

{ config, lib, pkgs, monego-font, ... }:

let
    HOSTNAME = "tpe14gen3";
    FIRST_INSTALL = "24.05"; # CHECK: update when reinstalling
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

    # to run gc manually use `nix-collect-garbage`
    nix.gc = {
        automatic = true;
        dates = "7 days"; # see: `man systemd.time`
        persistent = true; # run once if one or more runs were missed
    };

    # optimise (=hardlink identical files)
    # *) manually: `sudo nix-store --optimise`
    # *) with every build:
    #nix.settings.auto-optimise-store = true;
    # *) at regular intervals:
    nix.optimise = {
        automatic = true;
        dates = [ "20:00" ];
    };

    nixpkgs.config.allowUnfree = true;
    # use this instead of nixpkgs.config.packageOverrides:
    nixpkgs.overlays = [
        # widevine is google's proprietary DRM software required for spotify etc
        (final: prev: {chromium = prev.chromium.override { enableWideVine = true; }; })

    ];

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

    # Architectures to be able to emulate:
    boot.binfmt.emulatedSystems = [
        "aarch64-linux"     # =arm64
    ];

    boot.tmp.cleanOnBoot = true;    # clear /tmp on startup

    # kernel
    # unmaintained ones, such as outdated non-LTS, not available
    # specific ones such as linux_6_13 are in pkgs.linuxKernel.kernels.*
    # latest stable: pkgs.linuxPackages
    # latest release: pkgs.linuxPackages_latest
    # latest RC (=candidate): pkgs.linuxPackages_testing
    boot.kernelPackages = pkgs.linuxPackages_latest;

    console.keyMap = "de-latin1";

    time.timeZone = "Europe/Berlin";

    # sync time with a timeserver
    services.timesyncd.enable = true; # systemd-timesyncd

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

        ## nat is requird for nixos-containers to access internet
        #nat = {
        #    enable = true;
        #    internalInterfaces = [
        #        #"ve-acontainer"         # specific nixos-container
        #        #"ve-+"                 # all nixos-containers
        #    ];
        #    externalInterface = "wlp3s0";
        #};
    };

    # see: man 5 limits.conf
    security.pam.loginLimits = [
        # increase memlock to 64MB because otpclient complains otherwise
        # memlock is the amout of memory that will not be paged out
        { domain = "auser"; type = "-"; item = "memlock"; value = "65536" /*KiB*/; }
    ];

    hardware.bluetooth = {
        enable = true;
        powerOnBoot = false;        # whether to start bluetooth immediately on boot
    };
    services.blueman.enable = true; # also provides blueman-applet

    fonts = {
        enableDefaultPackages = true; # has noto-fonts-color-emoji -> monochrome cannot be preferred
        packages = with pkgs; [
            noto-fonts
            noto-fonts-cjk-sans
            #noto-fonts-cjk-serif
            noto-fonts-color-emoji      # already included when fonts.enableDefaultPackages=true
            #noto-fonts-monochrome-emoji # monochrome emojis CANNOT take precedence over colored ones

            google-fonts

            # windows fonts
            corefonts
            vista-fonts

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

    # printing (CUPS runs on http://localhost:631; foomatic is not needed when using CUPS, which we do)
    services.printing.enable = true;
    ## drivers; if nothing works, try connecting via the network: IPP-Eveywhere works without drivers
    #services.printing.drivers = with pkgs; [
    #
    #    # driver packages from nixpkgs:
    #    splix               # printers supporting SPL (Samsung-Printer-Language, not only used by samsung)
    #    samsung-unified-linux-driver # some Samsung printers
    #    gutenprint          # driver collection for various vendors
    #    gutenprintBin       # binary-only driver collection for various vendors
    #    hplip               # some HP printers
    #    hplipWithPlugin     # more HP printers; requires: `nix-shell -p hplipWithPlugin --run "sudo -E hp-setup"`
    #    postscript-lexmark  # printers from lexmark
    #    brlaser             # some Brother printers
    #    brgenml1lpr brgenml1cupswrapper # generic Brother drivers
    #    cnijfilter2         # some Canon Pixma printers
    #
    #    # manually downloaded drivers:
    #    #(writeTextDir "share/cups/model/HP_Color_Laser_MFP_17x_Series.ppd" (builtins.readFile ~/Downloads/hp-uld-drivers/uld/noarch/share/ppd/HP_Color_Laser_MFP_17x_Series.ppd))
    #];
    ## setup my known printers here in the config (optional)
    ## manually changing their settings later won't persist!
    ##hardware.printers = {
    ##    ensurePrinters = [
    ##        {
    ##            name = "";
    ##            location = "";
    ##            diviceUri = ""; # "http://..." or "usb://"
    ##            model = "SOME.PPD"; # might start with "drv:///..."
    ##            ppdOptions = {
    ##                PageSize = "A4";
    ##            };
    ##        }
    ##    ];
    ##};

    # scanning
    # NOTE: users must be in "scanner" and "lp" groups
    # NOTE: changes may need reboot
    hardware.sane = {
        enable = true;
        extraBackends = with pkgs; [
            sane-airscan    # airscan, ms wsd scanners NOTE: also add this to services.udev.packages
            #hplipWithPlugin # most hp scanners
            #epkowa          # epson scanners
            #utsushi         # more epson; NOTE: also add this to services.udev.packages
        ];

        # NOTE: downloadable/extracted scansnap snapscan firmware must be added to nixpkgs.config.sane.snapscanFirmware
        #drivers.scanSnap.enable = true;

        # brother brscan4 scanners can be enabled by importing the following module
        #<nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>
        # and then adding a scanner from it here:
        #brscan4 = {
        #    enable = true;
        #    netDevices = {
        #        home = { model = ""; ip = ""; };
        #    };
        #};

        #if scanners are found twice (once by airscan and once by escl) uncomment this:
        # disabledDefaultBackends = [ "escl" ];

        # find network scanners:
        openFirewall = true; # i believe its tcp port 6566
        # try to find scanners on these hosts:
        #netConf = ''
        #    192.168.0.1
        #    10.0.0.1
        #'';
    };
    #nixpkgs.config.sane.snapscanFirmware = pkgs.fetchurl { url = ""; sha256 = ""; };

    services.udev.packages = with pkgs; [
        sane-airscan    # airscan
        #utsushi         # some epson scanners
    ];

    # find network printers (udp port 5353) and scanners (see also: hardware.sane.openFirewall)
    services.avahi = {
        enable = true;
        openFirewall = true;
        nssmdns4 = true;
    };
    # driverless (airless) printing/scanning via usb cable
    # CHECK: is the service running? i had to run `systemctl start ipp-usb.service` once
    services.ipp-usb.enable = true;

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
            "application/pdf" = [ "org.gnome.Evince.desktop" "brave-browser.desktop"];
        };
    };

    hardware.graphics = {
        enable = true;
        enable32Bit = true;
        #extraPackages = with pkgs; [ ];
        #extraPackages32 = with pkgs; [ ];
    };

    # run unpatched linux executables
    programs.nix-ld = {
        enable = true;
        # put necessary libraries here (figure them out with ldd)
        #libraries = with pkgs; [];
    };

    # FLATPAKs
    # - NOTE: USER HAS TO MANUALLY MANAGE FLATPAKS!
    # - flatpaks can also be enabled per user by adding pkgs.flatpak to its packages
    # - when enabling them per user or with some DEs like sway one needs to manually
    #   export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
    services.flatpak.enable = true;
    systemd.services.my-default-global-flatpak-repos = {
        wantedBy = ["multi-user.target"];
        path = [ pkgs.flatpak ];
        script = ''
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
        '';
    };
    # - NOTE: if flatpaks complain about not finding fonts, try:
    #   1. enable fonts.fontDir.enable=true (done above)
    #   2. mkdir -p $HOME/.local/share/fonts
    #   3. cp --dereference /run/current-system/sw/share/X11/fonts/* $HOME/.local/share/fonts/
    #   4. do NOT grant flatpaks access to this font folder!

    # APPIMAGEs
    # - traditionally appimages are simply executed after making them executable:
    #   with `chmod u+x my.appimage; ./my.appimage [args...]`
    # - most of the time this fails on nixos due to hardcoded paths; instead run appimages
    #   with `appimage-run ./my.appimage [args...]`
    # - to do this automatically when executing an appimage set programs.appimage.binfmt=true;
    # - NOTE: if it still doesn't work (and there's no other way to install) package yourself
    #   using `appimageTools.wrapType2 { inherit name src; extraPkgs = pkgs: [pkgs.mydep]; };`
    #   see: https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-appimageTools
    programs.appimage = {
        enable = true;      # provides pkgs.appimage-run
        binfmt = true;      # automatically interpret `./my.appimage` as `appimage-run ./my.appimage`
    };

    environment.localBinInPath = true;
    environment.variables = {
        EDITOR = "nvim";
    };

    # virtualisation
    # kvm hyperviser
    boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
    # libvirt
    virtualisation.libvirtd = {
        enable = true;
        qemu = {
            swtpm.enable = true; # tpm emulation in qemu
        };
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

            adwaita-icon-theme      # provides cursor styles

            # make qt apps work
            qt6.qtwayland               # there is no qt6.full package anymore

            # etc
            pulsemixer              # graphically adjust volume
            xorg.xeyes              # to test whether apps are x11 or wayland
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

        # fix: flatpak paths
        export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share

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
        gsettings set org.gnome.desktop.interface cursor-size 32

        # Chromium/Electron
        export NIXOS_OZONE_WL=1

        # QT apps; require pkgs.qt6.qtwayland
        export QT_QPA_PLATFORM="wayland-egl;xcb"
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

    # # use other (mobile) device as graphic tablet
    # # careful which users are added, they have control over input!
    # programs.weylus = {
    #     enable = true;
    #     users = [ "auser" ];    # are added to "uinput" group
    #     openFirewall = false;   # tcp ports 1701 and 9001
    # };

    #
    # more global packages
    # these link some outputs to /run/current-system/sw/
    #

    environment.systemPackages = with pkgs; [
        bash-completion             # tab completion
        curl                        # make network requests
        easyeffects                 # apply audio effects
        file                        # identify filetype
        git
            gh                      # access to github accouts
        htop                        # process monitor
        killall                     # kill processes by name
        rclone                      # connect to cloud services
        usbutils                    # provides lsusb
        neovim                      # editor
        nix-prefetch                # determine hash for FODs
        tree                        # show nested folder structures
        typst                       # markup language targeting pdf
        wget                        # download files
        xdg-utils                   # open files appropriately

        # qemu
        qemu_full                   # virtualisation
        quickemu                    # preconfigured virtual machines

        # archives
        unzip

        system-config-printer       # gui printer setup; or use localhost:631

        # apps:
        brave                       # web browser
        evince                      # pdf viewer
        gedit                       # graphical file editor
        nautilus                    # graphical file manager
        simple-scan                 # scanner
        libreoffice-fresh           # document suite
        localsend                   # send,receive via local network # requires udp&tcp port 53317
        mpv                         # music,video player
        shotwell                    # image viewer
        signal-desktop              # private messenger
        snapshot                    # simple webcam
        webcamoid                   # webcam with effects such as flip, blur, pixelate
        kooha                       # screencast
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
        isNormalUser = true;        # adds to group "users", creates /home/NAME as user's home
        extraGroups = [
            "wheel"                 # allows elevating privileges
            "networkmanager"        # allows modifying connections
            "scanner"               # allows using scanners
            "lp"                    # allows using scanners which are also printers
            "kvm"                   # (virtualisation) improves android emulator performance
            "libvirtd"              # access to libvirtd daemon, used by virtual machine managers
        ];
        packages = with pkgs; [
            fd                      # find alternative
            fzf                     # for better bash history search (ctrl-r); see bashrc
            libfaketime             # provides faketime command
            pandoc                  # markup converter
            pdfcpu                  # pdf manipulation
            ripgrep                 # fast file content searcher
            tmux                    # terminal multiplexer
            scrcpy                  # "screen copy" shows phone screen on desktop

            # for my neovim config:
                gnumake             # make for mason.nvim
                nodejs              # npm for treesitter.nvim
                gcc                 # compile c and cpp
                cargo               # compile rust
                unixtools.xxd       # vim's hexviewer for hex.nvim

            # programming
            uv                      # per project python version + environment (install packages)
            zig                     # low level programming

            # apps:
            visidata                # tui csv editor
            otpclient               # otp client # NOTE: requires >=64MB memlock; see security.pam.loginLimits

            # games:
            zeroad                  # real time strategy, civ&army builder
        ];
    };

    users.users.buser = {
        initialPassword = "change_me_after_install";
        isNormalUser = true;
        extraGroups = [
            "kvm"           # (virtualisation) improves android emulator performance
            "libvirtd"      # access to libvirtd daemon, used by virtual machine managers
        ];
        packages = with pkgs; [
        ];
    };

    #
    # declarative nixos-containers:
    #

    # containers = {
    #     # container with a shared folder and network access (see: networking.nat)
    #     acontainer = let
    #         CONTAINERUSER = "acontaineruser";
    #     in {
    #         config = {config, lib, pkgs, ...}: {
    #             system.stateVersion = FIRST_INSTALL;
    #             environment = {
    #                 systemPackages = with pkgs; [
    #                     bash-completion
    #                     git
    #                     #neovim
    #                 ];
    #                 #variables = {
    #                 #    EDITOR = "nvim";
    #                 #};
    #             };
    #             users.users.${CONTAINERUSER} = {
    #                 isNormalUser = true;
    #                 initialPassword = "change_me_after_install";
    #                 #extraGroups = [ "wheel" ]; # sudo
    #             };
    #         };
    #         bindMounts.sharedfolder = {
    #             mountPoint = "/home/${CONTAINERUSER}/share_acontainer";
    #             hostPath = "/home/auser/share_acontainer";      # CHECK: must exist or breaks config
    #             isReadOnly = true;
    #         };
    #     };
    # };
}
