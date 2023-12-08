{ config, pkgs, username, hostname, ... }: {
    boot.consoleLogLevel = 0;
    boot.initrd.compressor = "lz4";
    boot.initrd.compressorArgs = [ "-l" "-9" ];
    boot.initrd.verbose = false;
    boot.kernel.sysctl = {
        "kernel.printk" = "3 3 3 3";
        "vm.swappiness" = 180;
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.page-cluster" = 0;
    };
    boot.kernelParams = [ "quiet" "systemd.show_status=auto" "udev.log_level=0" ];
    boot.loader.efi.canTouchEfiVariables = true; # TODO: windows?
    boot.loader.timeout = 0;
    boot.plymouth.enable = true;

    console.keyMap = "us";

    documentation.dev.enable = true;
    documentation.nixos.includeAllModules = true;

    # TODO: environment.etc

    environment.persistence."/nix/persist" = {
        directories = [
            "/etc/NetworkManager"
            "/etc/nixos"
            "/var/db/sudo"
            "/var/lib/systemd/timers"
        ];
        users."${username}" = {
            directories = [
                ".config/google-chrome"
                ".config/ArmCord"
                { directory = ".gnupg"; mode = "0700"; }
                { directory = ".ssh"; mode = "0700"; }
                ".local/state/zsh"

                "Desktop"
                "Documents"
                "Downloads"
                "Music"
                "Pictures"
                "Videos"
            ];
        };
    };

    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
        elisa
    ];
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
    hardware.opengl.enable = true;

    home-manager.users."${username}" = {
        # TODO: dconf.settings

        # TODO: gtk

        # TODO: home
        home.packages = with pkgs; [
            armcord
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
        # TODO: programs.nix-index
        programs.obs-studio.enable = true;
        programs.zsh.enable = true;
        programs.zsh.enableAutosuggestions = true;
        programs.zsh.completionInit = ''
        autoload -U compinit && compinit
        compinit -D $HOME/.local/state/zsh/compdump
        '';
        programs.zsh.dotDir = ".config/zsh";
        programs.zsh.envExtra = ''
        '';
        programs.zsh.history.path = ".local/state/zsh/history";
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
    networking.stevenblack.enable = true;
    networking.stevenblack.block = [ "fakenews" "gambling" "porn" ];

    # TODO: nix
    nix.gc.automatic = true;
    nix.optimise.automatic = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # TODO: nixpkgs
    nixpkgs.config.allowUnfree = true;

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

    qt.enable = true;
    qt.platformTheme = "kde";
    # qt.style = "kvantum";

    # TODO: security.pam.services
    security.polkit.enable = true;
    security.sudo.enable = true;
    security.sudo.execWheelOnly = true;
    # TODO: security.sudo.extraRules
    security.sudo.wheelNeedsPassword = true;

    # TODO: services.acpid
    # services.auto-cpufreq.enable = true;
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
    # TODO: services.getty
    # TODO: services.github-runner
    # TODO: services.gpm
    # TODO: services.greetd?
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
    # TODO: services.throttled
    services.timesyncd.enable = true;
    # TODO: services.tlp
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

    sound.enable = true;

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
    zramSwap.priority = 100;
}
