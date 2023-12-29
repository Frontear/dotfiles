{
    config,
    hostname,
    lib,
    pkgs,
    username,
    ...
}: {
    imports = [
        ../../modules
    ];

    boot.blacklistedKernelModules = [ "bluetooth" "snd_hda_codec_hdmi" ];
    boot.extraModprobeConfig = ''
    options i915 enable_fbc=1 enable_guc=3 enable_psr=2 fastboot=1
    options iwlmvm power_scheme=3
    options iwlwifi power_level=3 power_save=Y uapsd_disable=0
    options snd_hda_intel power_save=1 power_save_controller=Y
    '';
    boot.fast = true;
    boot.kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;
        "vm.dirty_writeback_centisecs" = 6000;
        "vm.dirty_ratio" = 3;
        "vm.dirty_background_ratio" = 1;
        "vm.laptop_mode" = 5;
        "vm.vfs_cache_pressure" = 50;
    };
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;
    boot.loader.efi.canTouchEfiVariables = true; # TODO: windows?
    boot.loader.systemd-boot.enable = true;
    boot.silent = true;

    documentation.dev.enable = true;
    documentation.man.generateCaches = true;
    documentation.nixos.includeAllModules = true;

    # TODO: environment.etc
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
    ];
    environment.systemPackages = with pkgs; [
    #    powerdevil
        powertop
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

    home-manager.users."${username}" = {
        # TODO: dconf.settings

        # TODO: gtk

        # TODO: home
        home.packages = with pkgs; [
            armcord
            fastfetch
            microsoft-edge
            vscode
        ];
        home.shellAliases = {
            l = "eza -lah --group-directories-first";
        };
        home.stateVersion = "24.05";

        manual.manpages.enable = true;

        # TODO: programs.dircolors
        programs.direnv.enable = true;
        programs.direnv.config = {
            whitelist = {
                prefix = [ "${config.users.extraUsers.${username}.home}/Documents/projects" ];
            };
        };
        programs.direnv.nix-direnv.enable = true;
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
        # programs.info.enable = true;
        # TODO: programs.java
        programs.jq.enable = true;
        programs.less.enable = true;
        programs.man.enable = true;
        programs.man.generateCaches = true;
        programs.obs-studio.enable = true;
        programs.zsh.enable = true;
        programs.zsh.enableAutosuggestions = true;
        programs.zsh.dotDir = ".config/zsh";
        programs.zsh.envExtra = ''
        '';
        programs.zsh.initExtra = ''
        PS1="%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b "
        RPS1="%B%(?.%F{green}.%F{red})%?%f%b" # https://unix.stackexchange.com/a/375730

        bindkey "$(echoti khome)"   beginning-of-line
        bindkey "$(echoti kend)"    end-of-line
        bindkey "$(echoti kich1)"   overwrite-mode
        bindkey "$(echoti kbs)"     backward-delete-char
        bindkey "$(echoti kdch1)"   delete-char
        bindkey "$(echoti kcuu1)"   up-line-or-history
        bindkey "$(echoti kcud1)"   down-line-or-history
        bindkey "$(echoti kcub1)"   backward-char
        bindkey "$(echoti kcuf1)"   forward-char
        bindkey "$(echoti kpp)"     beginning-of-buffer-or-history
        bindkey "$(echoti knp)"     end-of-buffer-or-history
        bindkey "$(echoti kcbt)"    reverse-menu-complete

        if echoti smkx && echoti rmkx; then
            autoload -Uz add-zle-hook-widget
            function zle_application_mode_start { echoti smkx }
            function zle_application_mode_stop { echoti rmkx }
            add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
            add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
        fi
        '';
        programs.zsh.shellAliases = {
            diff = "diff --color=auto";
            grep = "grep --color=auto";
        };
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

    impermanence = {
        enable = true;
        directories = [
            "/etc/NetworkManager"
            "/var/db/sudo"
            "/var/lib/systemd/timers"
        ];
        user_directories = [
            { directory = ".config/microsoft-edge"; mode = "0700"; }
            { directory = ".gnupg"; mode = "0700"; }
            ".local/share/kwalletd"
            { directory = ".ssh"; mode = "0700"; }

            { directory = ".config/Code"; mode = "0700"; }
            ".vscode"

            "Desktop"
            "Documents"
            "Downloads"
            "Music"
            "Pictures"
            "Videos"
        ];
        user_files = [
            ".zsh_history"
        ];
    };

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

    programs.command-not-found.enable = false;
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
    programs.xwayland.enable = true;

    qt.enable = true;
    qt.platformTheme = "kde";
    # qt.style = "kvantum";

    # TODO: security.pam.services
    security.polkit.enable = true;
    security.rtkit.enable = true;
    security.sudo.enable = true;
    security.sudo.execWheelOnly = true;
    security.sudo.extraRules = [
        {
            commands = [
                {
                    command = "${pkgs.powertop}/bin/powertop";
                    options = [ "NOPASSWD" ];
                }
            ];
            users = [
                "${username}"
            ];
        }
    ];
    security.sudo.wheelNeedsPassword = true;

    # TODO: services.acpid
    # TODO: services.auto-cpufreq
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
    # TODO: services.irqbalance
    # TODO: services.iptsd
    # TODO: services.jmusicbot
    # TODO: services.languagetool
    # TODO: services.localtimed
    # TODO: services.locate
    # TODO: services.minecraft-server
    # TODO: services.nextcloud
    # TODO: services.ntfy-sh
    # TODO: services.openssh
    # TODO: services.physlock
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
    systemd.tmpfiles.rules = [
        "z /sys/class/backlight/*/brightness 0644 - wheel - -"
        "w /sys/devices/system/cpu/cpu*/power/energy_perf_bias - - - - 8"
        "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
        "w /sys/module/pcie_aspm/parameters/policy - - - - powersupersave"
    ];
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
    services.xserver.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
    #services.xserver.desktopManager.plasma5.useQtScaling = true;
    services.xserver.displayManager.defaultSession = "plasmawayland";
    services.xserver.displayManager.sddm.enable = true;
    #services.xserver.displayManager.sddm.wayland.enable = true;

    sound.pipewire = true;

    system.stateVersion = "24.05";

    systemd.services."NetworkManager-wait-online".enable = false;

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
}
