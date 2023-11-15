{ pkgs, ... }:
{
    # silent boot
    boot.consoleLogLevel = 0;
    boot.initrd.verbose = false;
    boot.kernelParams = [ "quiet" "udev.log_level=3" ];
    boot.loader.timeout = 0;

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

    # plymouth
    boot.plymouth.enable = true;

    # TODO: environment.etc
    # TODO: environment.localBinInPath

    # disable some plasma5 packages
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
        khelpcenter
    ];

    # install neovim across the system (TODO: programs.neovim)
    environment = {
        systemPackages = [ pkgs.neovim ];
        variables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
        };
    };

    # part of impermanence
    fileSystems = {
        "/" = {
            device = "none";
            fsType = "tmpfs";
            noCheck = true; # TODO: necessary
            options = [ "defaults" "size=1G" "mode=755" ];
        };

        "/boot" = {
            device = "/dev/nvme0n1p1";
            fsType = "vfat";
        };

        "/nix" = {
            device = "/dev/nvme0n1p4";
            fsType = "ext4";
        };
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
    }

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

    # add my user and disable any user mutating (part of impermanence)
    users.extraUsers."frontear" = {
        extraGroups = [ "wheel" "networkmanager" ];
        initialHashedPassword = "$y$j9T$egLJSMMd/l4M3n8BuZ3W7/$AOR0P9FLDq5vh6oVJ48TaijmMWP519MyurNmR041UJ3";
        isNormalUser = true;

        # TODO: openssh
    };
    users.mutableUsers = false;

    # TODO: xdg.portal

    # use a zram device for swapping TODO: set swappiness
    zramSwap = {
        enable = true;
        priority = 100;
    };
}
