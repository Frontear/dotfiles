{ lib, pkgs, ... }: let
    impermanence = builtins.fetchGit { url = "https://github.com/nix-community/impermanence.git"; };
    home-manager = builtins.fetchGit { url = "https://github.com/nix-community/home-manager.git"; };
in {
    imports = [
        ./hardware-configuration.nix
        "${impermanence}/nixos.nix"
        "${home-manager}/nixos"
    ];

    # silent boot
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;
    boot.kernelParams = [ "quiet" "udev.log_level=3" ];
    boot.loader.timeout = 0;
    boot.plymouth.enable = true;

    # kernel compression
    boot.initrd.compressor = "lz4";
    boot.initrd.compressorArgs = [ "-l" "-9" ];

    # liquorix kernel
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;

    # systemd-boot
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot = {
        enable = true;

        configurationLimit = 5;
        memtest86.enable = true;
    };

    # TODO: environment.etc
    # TODO: environment.localBinInPath

    # set some files to persist from impermanence
    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/NetworkManager/system-connections"
            "/etc/nixos"

            "/var/db/sudo/lectured"
            "/var/log"
        ];
        files = [
            "/etc/machine-id" # needed for /var/log, as it keeps files based on machine-id
        ];
    };

    # setup plasma5 on system and remove some extra packages
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
        khelpcenter
    ];

    services.xserver = {
        enable = true;
        desktopManager.plasma5.enable = true;
        displayManager = {
            defaultSession = "plasmawayland";
            sddm.enable = true;
        };
    };

    # configure user via home-manager with apps and app settings
    home-manager.users."frontear" = {
        home.packages = with pkgs; [
            armcord
            fastfetch
            google-chrome
            gparted
            vscode
        ];
        programs = {
            git = {
                enable = true;
                extraConfig = {
                    init.defaultBranch = "main";
                };
                signing = {
                    key = "BCB5CEFDE22282F5";
                    signByDefault = true;
                };
                userEmail = "perm-iterate-0b@icloud.com";
                userName = "Ali Rizvi";
            };
            gpg = {
                enable = true;
            };
            zsh = {
                enable = true;
                enableAutosuggestions = true;
                initExtra =
                ''
                autoload -U promptinit && promptinit && prompt redhat && setopt prompt_sp
                '';
                syntaxHighlighting.enable = true;
            };
        };
        services = {
            gpg-agent = {
                enable = true;
                enableSshSupport = true;
                pinentryFlavor = null;
            };
        };

        home.stateVersion = "23.11";
    };
 
    # install neovim across the system
    programs.neovim = {
        enable = true;
        configure = {
            customRC =
            ''
            set tabstop=4
            set shiftwidth=4
            set expandtab
            '';
        };
        defaultEditor = true;
    };

    # TODO: fonts

    # enables all firmware, even for things that aren't "free"
    nixpkgs.config.allowUnfree = true;
    hardware.enableAllFirmware = true;

    # TODO: hardware

    # explicitly enables microcode updates
    hardware.cpu = {
        amd.updateMicrocode = true;
        intel.updateMicrocode = true;
    };

    # adds va-api/vdapu drivers for OpenGL
    hardware.opengl.extraPackages = with pkgs; [ intel-media-driver intel-ocl ];

    # hdd/ssd temp sensors?
    hardware.sensor.hddtemp = {
        enable = true;
        drives = [ "/dev/nvme0n1" ];
    };

    # wireless regulatory database
    hardware.wirelessRegulatoryDatabase = true;

    # set system locale
    i18n.defaultLocale = "en_US.UTF-8";

    # TODO: location

    # TODO: networking

    # TODO: networking.firewall

    # sets system hostname
    networking.hostName = "frontear-net";

    # set dns to cloudflare ones and disable networkmanager dns resolution
    networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
    ];
    networking.networkmanager.dns = "none";

    # use network manager
    networking.networkmanager.enable = true;

    # TODO: networkmanager.wifi.powersave

    # enable stevenblack hosts
    networking.stevenblack = {
        enable = true;
        block = [ "fakenews" "gambling" "porn" "social" ];
    };

    # clean up nix store and optimise it
    nix = {
        gc.automatic = true;
        optimise.automatic = true;
    };

    # TODO: nix.settings

    # TODO powerManagement

    # TODO: programs

    # TODO: qt

    # TODO: security.pam

    # TODO: security.polkit

    # prevent non-wheel users from even running sudo
    security.sudo.execWheelOnly = true;

    # TODO: services

    # enable sound TODO: add pipewire
    sound.enable = true;

    # TODO: swapDevices

    # TODO: system.autoUpgrade?

    # TODO: system.copySystemConfiguration?

    # Set system state version, never change this
    system.stateVersion = "23.11";

    # TODO: systemd

    # sets timezone
    time.timeZone = "America/Toronto";

    # add my user and disable any user mutating (part of impermanence), and add zsh (configuration done in home-manager)
    programs.zsh.enable = true;
    users.extraUsers."frontear" = {
        extraGroups = [ "wheel" "networkmanager" ];
        initialHashedPassword = "$y$j9T$egLJSMMd/l4M3n8BuZ3W7/$AOR0P9FLDq5vh6oVJ48TaijmMWP519MyurNmR041UJ3";
        isNormalUser = true;

        # TODO: openssh

        shell = pkgs.zsh;
    };
    users.mutableUsers = false;

    # TODO: xdg.portal

    # use a zram device for swapping TODO: set swappiness
    zramSwap = {
        enable = true;
        priority = 100;
    };
}
