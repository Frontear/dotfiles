{ config, lib, pkgs, hostname, ... }: {
    boot.blacklistedKernelModules = [ "bluetooth" ];
    boot.consoleLogLevel = 0;
    boot.extraModprobeConfig = ''
    options i915 enable_fbc=1 enable_psr=2 fastboot=1 enable_guc=3
    options iwlwifi uapsd_disable=0 power_save=1 power_level=3
    options iwlmvm power_scheme=3
    '';
    boot.initrd.compressor = "lz4";
    boot.initrd.compressorArgs = [ "-l" "-9" ];
    boot.initrd.verbose = false;
    boot.kernel.sysctl = {
        "kernel.printk" = "3 3 3 3";
        
        #"vm.swappiness" = 180;
        #"vm.watermark_boost_factor" = 0;
        #"vm.watermark_scale_factor" = 125;
        #"vm.page-cluster" = 0;
        
        "kernel.nmi_watchdog" = 0;
        "vm.dirty_writeback_centisecs" = 6000;
        "vm.dirty_ratio" = 3;
        "vm.dirty_background_ratio" = 1;
        "vm.laptop_mode" = 5;
        "vm.vfs_cache_pressure" = 50;
    };
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;
    boot.kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];
    boot.loader.efi.canTouchEfiVariables = true; # TODO: windows?
    boot.loader.systemd-boot.enable = true;
    boot.loader.timeout = 0;
    boot.plymouth.enable = true;

    console.keyMap = "us";

    documentation.dev.enable = true;
    documentation.nixos.includeAllModules = true;

    # TODO: environment.etc

    environment.systemPackages = with pkgs; [
        # powerdevil
    ];
    environment.wordlist.enable = false; # TODO: wtf is wrong with the encoding

    fileSystems = {
        "/" = {
            device = "none";
            fsType = "tmpfs";
            options = [ "defaults" "mode=755" "noatime" "size=1G" ];
        };
        "/archive" = {
            device = "/dev/disk/by-label/archive";
            fsType = "btrfs";
            options = [ "defaults" "compress=zstd:15" ];
        };
        "/boot" = {
            device = "/dev/disk/by-label/EFI";
            fsType = "vfat";
            options = [ "defaults" "noatime" ];
        };
        "/nix" = {
            device = "/dev/disk/by-label/nix";
            fsType = "btrfs";
            options = [ "defaults" "compress=zstd" "noatime" ];
        };
    };

    fonts.enableDefaultPackages = true;
    fonts.fontDir.enable = true;
    fonts.fontDir.decompressFonts = true;
    fonts.fontconfig.enable = true;

    gtk.iconCache.enable = true;

    hardware.enableAllFirmware = true;
    hardware.bluetooth.enable = false;
    hardware.cpu.intel.updateMicrocode = true;
    hardware.opengl.enable = true;
    hardware.opengl.extraPackages = with pkgs; [
        intel-media-driver
        intel-ocl
        intel-vaapi-driver
        libvdpau-va-gl
        vaapiVdpau
    ];

    i18n.defaultLocale = "en_US.UTF-8";

    location.provider = "geoclue2";

    # TODO: nix
    nix.gc.automatic = true;
    nix.optimise.automatic = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # TODO: nixpkgs
    nixpkgs.config.allowUnfree = true;

    powerManagement.enable = true;
    powerManagement.cpuFreqGovernor = "powersave";
    powerManagement.cpufreq.max = 3000000;
    powerManagement.scsiLinkPolicy = "med_power_with_dipm";

    #programs.command-not-found.enable = false;
    programs.nano.enable = false;
    programs.neovim.enable = true;
    programs.neovim.configure.customRC = ''
    set tabstop=4
    set shiftwidth=4
    set expandtab

    set number
    highlight LineNr ctermfg=grey
    '';
    programs.neovim.configure.packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ nvim-treesitter.withAllGrammars ];
    };
    programs.neovim.defaultEditor = true;
    #programs.nix-index.enable = true;
    programs.xwayland.enable = true;

    # qt.style = "kvantum";

    # TODO: security.pam.services
    security.polkit.enable = true;
    security.rtkit.enable = true;
    security.sudo.enable = true;
    security.sudo.execWheelOnly = true;
    # TODO: security.sudo.extraRules
    security.sudo.wheelNeedsPassword = true;

    # TODO: services.acpid
    # services.auto-cpufreq.enable = true;
    services.automatic-timezoned.enable = true;
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.openFirewall = true;
    # TODO: services.beesd
    services.btrfs.autoScrub.enable = true;
    services.btrfs.autoScrub.fileSystems = [ "/archive" "/nix" ];
    # TODO: services.colord
    # TODO: services.cron/services.fcron
    # TODO: services.earlyoom (disable systemd.oom-killer if choose this)
    # TODO: services.fprintd
    # TODO: services.fractalart
    services.fstrim.enable = true;
    services.fwupd.enable = true;
    # TODO: services.getty
    services.geoclue2.enable = true;
    # TODO: services.github-runner
    # TODO: services.gpm
    # TODO: services.greetd?
    services.hardware.bolt.enable = true;
    # TODO: services.hddfancontrol
    # TODO: services.httpd
    # TODO: services.infnoise
    # TODO: services.iptsd
    # TODO: services.irqbalance
    # TODO: services.jmusicbot
    # TODO: services.languagetool
    # TODO: services.localtimed
    # TODO: services.locate
    # TODO: services.minecraft-server
    # TODO: services.nextcloud
    # TODO: services.ntfy-sh
    # TODO: services.openssh
    # TODO: services.physlock
    services.pipewire.enable = true;
    services.pipewire.alsa.enable = true;
    services.pipewire.audio.enable = true;
    services.pipewire.jack.enable = true;
    services.pipewire.pulse.enable = true;
    services.pipewire.wireplumber.enable = true;
    services.printing.enable = true;
    services.printing.cups-pdf.enable = true;
    services.printing.drivers = with pkgs; [
        brgenml1cupswrapper
        brgenml1lpr
        brlaser
        gutenprint
        gutenprintBin
        foomatic-db-ppds-withNonfreeDb
    ];
    services.printing.openFirewall = true;
    # TODO: services.psd
    # TODO: services.redshift
    # TODO: services.smartd
    # TODO: services.system-config-printer
    services.thermald.enable = true;
    # TODO: services.throttled
    services.timesyncd.enable = true;
    # TODO: services.tlp
    services.udev.extraRules = ''
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    SUBSYSTEM=="scsi", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    '';
    # TODO: services.udisks2
    # TODO: services.unclutter
    # TODO: services.upower
    # TODO: services.usbguard
    # TODO: services.usbmuxd
    #services.xserver.desktopManager.plasma5.useQtScaling = true;
    #services.xserver.displayManager.sddm.wayland.enable = true;

    sound.enable = lib.mkForce false;

    system.stateVersion = "24.05";

    systemd.tmpfiles.rules = [
        "z /sys/class/backlight/*/brightness 0644 - wheel - -"
        "w /sys/devices/system/cpu/cpu*/power/energy_perf_bias - - - - 8"
        "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
        "w /sys/module/pcie_aspm/parameters/policy - - - - powersupersave"
    ];

    time.timeZone = "America/Toronto";

    # TODO: users

    xdg.portal.enable = true;
    # xdg.portal.config = {};
    # xdg.portal.extraPortals = with pkgs; [
    #     xdg-desktop-portal-hyprland
    # ];
}
