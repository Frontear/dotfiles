{ config, pkgs, username, hostname, ... }:
{
    imports = [
        ./hardware-configuration.nix

        ./temp.nix
    ];

    boot.blacklistedKernelModules = [ "bluetooth" "snd_hda_codec_hdmi" ];
    boot.consoleLogLevel = 0; # was 3
    boot.extraModprobeConfig = ''
    options i915 enable_fbc=1 enable_psr=2 fastboot=1 enable_guc=3
    options iwlwifi uapsd_disable=0 power_save=1 power_level=3
    options iwlmvm power_scheme=3
    options snd_hda_intel power_save=1 power_save_controller=y
    '';
    boot.initrd.compressor = "lz4";
    boot.initrd.compressorArgs = [ "-l" "-9" ];
    # TODO: services.udev.extraRules?
    boot.initrd.services.udev.rules = ''
    SUBSYSTEM=="pci", ATTR{power/control}="auto"
    SUBSYSTEM=="scsi", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    '';
    boot.initrd.verbose = false;
    boot.kernel.sysctl = {
        "kernel.printk" = "3 3 3 3";
        "vm.swappiness" = 180;
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.page-cluster" = 0;
        "kernel.nmi_watchdog" = 0;
        "vm.dirty_writeback_centisecs" = 6000;
        "vm.dirty_ratio" = 3;
        "vm.dirty_background_ratio" = 1;
        "vm.laptop_mode" = 5;
        "vm.vfs_cache_pressure" = 50;
    };
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;
    boot.kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;
    boot.loader.timeout = 0;
    boot.plymouth.enable = true; # NEW

    console.keyMap = "us";

    documentation.dev.enable = true;
    documentation.nixos.includeAllModules = true;

    # TODO: environment.etc

    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/NetworkManager/system-connections"
            "/etc/nixos"
            "/var/db/sudo"
        ];
        users."${username}" = {
            directories = [
                "Desktop"
                "Documents"
                "Downloads"
                "Music"
                "Pictures"
                "Videos"
                
                ".config/google-chrome"
                { directory = ".gnupg"; mode = "0700"; }
            ];
            files = [
                ".zsh_history"
            ];
        };
    };

    environment.systemPackages = with pkgs; [
        # powerdevil
    ];

    fileSystems = {
        "/" = {
            device = "none";
            fsType = "tmpfs";
            options = [ "defaults" "mode=755" "noatime" "size=1G" ];
        };
        "/archive" = {
            device = "/dev/nvme0n1p3";
            fsType = "btrfs";
            options = [ "compress=zstd:15" "defaults" ];
        };
        "/boot" = {
            device = "/dev/nvme0n1p1";
            fsType = "vfat";
            options = [ "defaults" "noatime" ];
        };
        "/nix" = {
            device = "/dev/nvme0n1p2";
            fsType = "btrfs";
            options = [ "compress=zstd" "defaults" "noatime" ];
        };
    };

    fonts.enableDefaultPackages = true;
    fonts.fontDir.enable = true;
    fonts.fontDir.decompressFonts = true;
    fonts.fontconfig.enable = true;

    gtk.iconCache.enable = true;

    hardware.enableAllFirmware = true;
    hardware.bluetooth.enable = false;
    # hardware.cpu.amd.updateMicrocode = true;
    hardware.cpu.intel.updateMicrocode = true;
    hardware.opengl.enable = true;
    hardware.opengl.extraPackages = with pkgs; [
        intel-media-driver
        intel-ocl
        intel-vaapi-driver
        libvdpau-va-gl
    ];

    home-manager.users."${username}" = {
        # TODO: dconf.settings

        # TODO: gtk

        # TODO: home
        home.packages = with pkgs; [
            fastfetch
        ];
        home.shellAliases = {
            l = "eza -lah --group-directories-first";
        };
        home.stateVersion = "24.05";

        manual.manpages.enable = true;

        # TODO: programs.command-not-found (system has this too)
        programs.chromium.enable = true;
        programs.chromium.package = pkgs.google-chrome;
        programs.chromium.commandLineArgs = [ "--disk-cache-dir=/tmp/chrome-cache" ];
        programs.chromium.dictionaries = with pkgs.hunspellDictsChromium; [ en_US ];
        # TODO: programs.dircolors
        programs.eza.enable = true;
        programs.eza.enableAliases = true;
        programs.eza.extraOptions = [ "--group-directories-first" "--header" ];
        programs.git.enable = true;
        programs.git.extraConfig.init.defaultBranch = "main";
        programs.git.lfs.enable = true;
        programs.git.signing.key = "BCB5CEFDE22282F5";
        programs.git.signing.signByDefault = true;
        programs.git.userEmail = "perm-iterate-0b@icloud.com";
        programs.git.userName = "Ali Rizvi";
        programs.gpg.enable = true;
        programs.home-manager.enable = true;
        programs.info.enable = true;
        # TODO: programs.java
        programs.jq.enable = true;
        programs.less.enable = true;
        programs.man.enable = true;
        programs.man.generateCaches = true;
        # TODO: programs.nix-index
        programs.obs-studio.enable = true;
        programs.zsh.enable = true;
        programs.zsh.enableAutosuggestions = true;
        programs.zsh.initExtra = ''
        autoload -U promptinit && promptinit && prompt redhat && setopt prompt_sp
        '';
        programs.zsh.syntaxHighlighting.enable = true;

        # TODO: qt

        # services.cliphist.enable = true;
        # TODO: services.clipman/services.clipmenu/...
        # TODO: services.darkman
        services.gpg-agent.enable = true;
        services.gpg-agent.enableExtraSocket = true;
        services.gpg-agent.enableSshSupport = true;
        services.gpg-agent.pinentryFlavor = "curses";
        services.gpg-agent.sshKeys = [ "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2" ];
        # TODO: services.random-background
        # TODO: services.redshift
        # TODO: services.udiskie
        # TODO: services.wlsunset

        # TODO: xdg
        xdg.enable = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";

    location.provider = "geoclue2";

    networking.dhcpcd.enable = false;
    networking.firewall.enable = true;
    networking.hostName = "${hostname}";
    networking.nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
    ];
    networking.networkmanager.enable = true;
    networking.networkmanager.dhcp = "internal";
    networking.networkmanager.dns = "none";
    networking.networkmanager.wifi.powersave = true;
    networking.stevenblack.enable = true;
    networking.stevenblack.block = [ "fakenews" "gambling" "porn" ];

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

    #qt.enable = true;
    #qt.platformTheme = "qt6ct";
    #qt.style = "kvantum";

    # TODO: security.pam.services
    security.polkit.enable = true;
    security.sudo.enable = true;
    security.sudo.execWheelOnly = true;
    # TODO: security.sudo.extraRules
    security.sudo.wheelNeedsPassword = true;

    # TODO: services.acpid
    # services.auto-cpufreq.enable = true;
    services.automatic-timezoned.enable = true;
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
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
    services.geoclue2.enable = true;
    # TODO: services.getty
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
    # TODO: services.udisks2
    # TODO: services.unclutter
    # TODO: services.upower
    # TODO: services.usbguard
    # TODO: services.usbmuxd

    sound.enable = true;

    system.stateVersion = "24.05";

    systemd.services."NetworkManager-wait-online".enable = false;
    systemd.tmpfiles.rules = [
        "z /sys/class/backlight/*/brightness 0644 - wheel - -"
        "w /sys/devices/system/cpu/cpu*/power/energy_perf_bias - - - - 8"
        "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
        "w /sys/module/pcie_aspm/parameters/policy - - - - powersupersave"
    ];

    time.timeZone = "America/Toronto";

    # TODO: users
    users.extraUsers."${username}" = {
        extraGroups = [ "networkmanager" "wheel" ];
        ignoreShellProgramCheck = true;
        initialHashedPassword = "$y$j9T$Lu2JSULdxszq90smP9wZW1$BEFwPllaKcrpyA6o3ZCcugYPrWKWWkzdvECi0qtN8JD";
        isNormalUser = true;
        shell = pkgs.zsh;
    };
    users.mutableUsers = false;
    users.users."root".initialHashedPassword = config.users.extraUsers."${username}".initialHashedPassword;

    xdg.portal.enable = true;
    # xdg.portal.config = {};
    # xdg.portal.extraPortals = with pkgs; [
    #     xdg-desktop-portal-hyprland
    # ];

    zramSwap.enable = true;
    zramSwap.priority = 100;
}
