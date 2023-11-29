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
        programs.kitty.enable = true;
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

        wayland.windowManager.hyprland.enable = true;
        wayland.windowManager.hyprland.extraConfig = ''
        # https://wiki.hyprland.org/

# monitor=HDMI-A-1,3840x2160@30,0x0,2
# monitor=eDP-1,1920x1080@60,0x0,1,mirror,HDMI-A-1
monitor=,preferred,auto,1

#exec-once = mako # TODO: replace with ags
#exec-once = polkit-dumb-agent
exec-once = ~/.config/hypr/scripts/ags_load
exec-once = ~/.config/hypr/scripts/wallpaper_load
exec-once = ~/.config/hypr/scripts/clipboard_load
#exec-once = udiskie

#exec-once = pass-secrets

env = GDK_SCALE,1
env = XCURSOR_SIZE,24
env = GDK_BACKEND,wayland,x11
env = WLR_NO_HARDWARE_CURSORS,1
#env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_QPA_PLATFORM,wayland;xcb
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

general {
    sensitivity = 1.0 # DO NOT CHANGE
    border_size = 2
    no_border_on_floating = false
    gaps_in = 2
    gaps_out = 8
    col.inactive_border = rgba(595959aa)
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    # col.nogroup_border
    # col.nogroup_border_active
    cursor_inactive_timeout = 5
    layout = dwindle
    no_cursor_warps = false
    no_focus_fallback = false
    apply_sens_to_raw = false # DO NOT CHANGE
    resize_on_border = false
    # extend_border_grab_area
    # hover_icon_on_border
    allow_tearing = false
}

decoration {
    rounding = 8
    active_opacity = 1.0
    inactive_opacity = 1.0
    fullscreen_opacity = 1.0
    drop_shadow = false
    # shadow_range
    # shadow_render_power
    # shadow_ignore_window
    # col.shadow
    # col.shadow_inactive
    # shadow_offset
    # shadow_scale
    dim_inactive = false
    # dim_strength
    # dim_special
    # dim_around
    # screen_shader = ~/.config/hypr/shaders/nightlight.glsl

    blur {
        enabled = true
        size = 4
        passes = 1
        ignore_opacity = false
        new_optimizations = true
        xray = true
        noise = 0.0117
        contrast = 0.8916
        brightness = 0.8172
        special = false
    }
}

# https://wiki.hyprland.org/Configuring/Animations/
animations {
    enabled = true

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_model = pc105+inet
    kb_layout = us
    # kb_variant
    kb_options = terminate:ctrl_alt_bksp
    # kb_rules
    # kb_file
    numlock_by_default = false
    repeat_rate = 25
    repeat_delay = 500
    sensitivity = 0.0
    # accel_profile
    force_no_accel = false
    left_handed = false
    scroll_method = no_scroll
    scroll_button = 0
    scroll_button_lock = 0
    # natural_scroll
    follow_mouse = 1
    mouse_refocus = true
    float_switch_override_focus = 1

    touchpad {
        disable_while_typing = true
        natural_scroll = true
        scroll_factor = 1.0
        middle_button_emulation = true
        tap_button_map = lrm
        clickfinger_behavior = true
        tap-to-click = false
        drag_lock = false
        tap-and-drag = false
    }

    # touchdevice {}
    # tablet {}
}

gestures {
    workspace_swipe = false
    # workspace_swipe_fingers
    # workspace_swipe_distance
    # workspace_swipe_invert
    # workspace_swipe_min_speed_to_force
    # workspace_swipe_cancel_ratio
    # workspace_swipe_create_new
    # workspace_swipe_direction_lock
    # workspace_swipe_direction_lock_threshold
    # workspace_swipe_forever
    # workspace_swipe_numbered
    # workspace_swipe_use_r
}

group {
    insert_after_current = true
    focus_removed_window = true
    # col.border_active
    # col.border_inactive
    # col.border_locked_active
    # col.border_locked_inactive

    groupbar {
        font_size = 8
        gradients = true
        render_titles = true
        scrolling = true
        text_color = rgba(ffffffff)
        # col.active
        # col.inactive
        # col.locked_active
        # col.locked_inactive
    }
}



misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    force_default_wallpaper = -1
    force_hypr_chan = false
    vfr = true
    vrr = 0 # https://wiki.hyprland.org/FAQ/#my-monitor-has-flickering-brightness-when-i-turn-on-vrr
    mouse_move_enables_dpms = false
    key_press_enables_dpms = true
    always_follow_on_dnd = true
    layers_hog_keyboard_focus = true
    animate_manual_resizes = false
    animate_mouse_windowdragging = false
    disable_autoreload = false
    enable_swallow = false
    # swallow_regex
    # swallow_exception_regex
    focus_on_activate = false
    no_direct_scanout = true
    hide_cursor_on_touch = false
    mouse_move_focuses_monitor = true
    render_ahead_of_time = false # DO NOT CHANGE
    # render_ahead_safezone
    cursor_zoom_factor = 1.0
    cursor_zoom_rigid = false
    allow_session_lock_restore = false
    background_color = rgba(000000ff)
    close_special_on_empty = true
}

binds {
    pass_mouse_when_bound = false
    scroll_event_delay = 300
    workspace_back_and_forth = false
    allow_workspace_cycles = false
    focus_preferred_method = 0
    ignore_group_lock = false
}

xwayland {
    use_nearest_neighbor = true
    force_zero_scaling = true
}

# https://wiki.hyprland.org/Configuring/Dwindle-Layout/
dwindle {
    pseudotile = false
    force_split = 0
    preserve_split = true
    smart_split = false
    smart_resizing = false
    permanent_direction_override = false
    special_scale_factor = 0.8
    split_width_multiplier = 1.0
    no_gaps_when_only = 0
    use_active_for_splits = true
    default_split_ratio = 1.0
}

# https://wiki.hyprland.org/Configuring/Master-Layout/
master {
    allow_small_split = false
    special_scale_factor = 0.8
    mfact = 0.55
    new_is_master = true
    new_on_top = false
    no_gaps_when_only = 0
    orientation = left
    inherit_fullscreen = true
    always_center_master = false
    smart_resizing = false
}

# https://wiki.hyprland.org/Configuring/Window-Rules/
windowrulev2 = opacity 0.7,class:^kitty$
windowrulev2 = float, class:^wev$

# TODO: implications of Super_L vs. Super
$mainMod = Super_L

bindlt  =,                  XF86AudioMute,          exec, ~/.local/bin/sysd audio --mute
bindet  =,                  XF86AudioLowerVolume,   exec, ~/.local/bin/sysd audio --decrease
bindet  =,                  XF86AudioRaiseVolume,   exec, ~/.local/bin/sysd audio --increase
bindlet =,                  XF86MonBrightnessDown,  exec, ~/.local/bin/sysd backlight --decrease
bindlet =,                  XF86MonBrightnessUp,    exec, ~/.local/bin/sysd backlight --increase

bindr =,                    Print,                  exec, ~/.config/hypr/scripts/screenshot

bind = $mainMod,            Return,                 exec, kitty
bind = $mainMod,            BackSpace,              killactive
bind = $mainMod,            e,                      exec, ags -t hyprrunner
bind = Control_L Alt_L,     Delete,                 exit

bind = $mainMod,            Left,                   movefocus, l
bind = $mainMod,            Right,                  movefocus, r
bind = $mainMod,            Up,                     movefocus, u
bind = $mainMod,            Down,                   movefocus, d
bind = $mainMod Shift_L,    Left,                   movewindow, l
bind = $mainMod Shift_L,    Right,                  movewindow, r
bind = $mainMod Shift_L,    Up,                     movewindow, u
bind = $mainMod Shift_L,    Down,                   movewindow, d

bind = $mainMod,            1,                      workspace, 1
bind = $mainMod,            2,                      workspace, 2
bind = $mainMod,            3,                      workspace, 3
bind = $mainMod,            4,                      workspace, 4
bind = $mainMod,            5,                      workspace, 5
bind = $mainMod,            6,                      workspace, 6
bind = $mainMod,            7,                      workspace, 7
bind = $mainMod,            8,                      workspace, 8
bind = $mainMod,            9,                      workspace, 9
bind = $mainMod,            0,                      workspace, 10
bind = $mainMod Shift_L,    1,                      movetoworkspace, 1
bind = $mainMod Shift_L,    2,                      movetoworkspace, 2
bind = $mainMod Shift_L,    3,                      movetoworkspace, 3
bind = $mainMod Shift_L,    4,                      movetoworkspace, 4
bind = $mainMod Shift_L,    5,                      movetoworkspace, 5
bind = $mainMod Shift_L,    6,                      movetoworkspace, 6
bind = $mainMod Shift_L,    7,                      movetoworkspace, 7
bind = $mainMod Shift_L,    8,                      movetoworkspace, 8
bind = $mainMod Shift_L,    9,                      movetoworkspace, 9
bind = $mainMod Shift_L,    0,                      movetoworkspace, 10

# bind = $mainMod, V, togglefloating,
# bind = $mainMod, P, pseudo, # dwindle
# bind = $mainMod, J, togglesplit, # dwindle
'';
        wayland.windowManager.hyprland.xwayland.enable = true;

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
