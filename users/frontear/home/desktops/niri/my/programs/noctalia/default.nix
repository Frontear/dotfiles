{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    my.programs.noctalia = {
      enable = true;

      settings = {
        ### ====== Appearance =====
        ## ===== Theme =====
        # theme.mode = "dark";
        # theme.source = "builtin";
        # theme.custom_palette = "MyPalette";
        # theme.pure_black_dark = false;

        ## ===== Interface =====
        # shell.font_family = "sans-serif";
        shell.lang = ""; # "" == auto-detect language from locale
        shell.corner_radius_scale = 1.0;
        shell.app_icon_colorize = false;

        ## ===== Accessibility =====
        accessibility.ui_scale = 1.0;
        accessibility.high_contrast = false;

        ## ===== Motion =====
        shell.animation.enabled = true;
        shell.animation.speed = 1.0;

        ## ===== Borders =====
        shell.button_borders = true;
        shell.input_borders = true;
        shell.popup_borders = true;
        shell.card_borders = true;

        ## ===== Effects =====
        shell.shadow.direction = "down";
        shell.shadow.alpha = 0.55;
        shell.popup_shadows = true;

        ### ===== Wallpaper =====
        ## ===== General =====
        wallpaper.enabled = true;
        # wallpaper.fill_mode = "crop";
        # wallpaper.fill_color = "#111111";

        ## ===== Directories =====
        wallpaper.directory = pkgs.runCommand "wallpaper-directory" {} ''
          mkdir -p $out
          cp ${../../../stylix/assets/bg_dark.jpg} $out
        '';
        # wallpaper.directory_light = "";
        # wallpaper.directory_dark = "";
        # wallpaper.per_monitor_directories = false;

        ## ===== Transition =====
        wallpaper.transition = [
          "fade"
          "wipe"
          "disc"
          "stripes"
          "zoom"
          "honeycomb"
        ];
        wallpaper.transition_duration = 1500;
        wallpaper.edge_smoothness = 0.3;
        wallpaper.transition_on_startup = false;

        ## ===== Automation =====
        wallpaper.automation.enabled = false;
        wallpaper.automation.interval_seconds = 1800;
        wallpaper.automation.order = "random";
        wallpaper.automation.recursive = true;

        ### ===== Templates =====
        ## ===== Built-In =====
        theme.templates.enable_builtin_templates = false;

        ## ===== Community =====
        theme.templates.enable_community_templates = false;

        ### ===== Desktop =====
        ## ===== Widgets =====
        desktop_widgets.enabled = false;

        ## ===== Screen Corners =====
        shell.screen_corners.enabled = false;
        shell.screen_corners.size = 32;

        ## ===== Hot Corners =====
        hot_corners.enabled = false;

        ### ===== Dock =====
        ## ===== General =====
        dock.enabled = false;

        ### ===== Launcher =====
        ## ===== Launcher =====
        shell.panel.launcher_placement = "floating";
        shell.panel.launcher_position = "center";
        shell.launcher.categories = false;
        shell.launcher.show_icons = true;
        shell.launcher.app_grid = false;
        shell.launcher.compact = false;
        shell.launcher.sort_by_usage = true;
        shell.launcher.fetch_exchange_rates = true;
        shell.launcher.auto_paste = "auto";

        ## ===== Providers =====
        shell.launcher.provider_prefix = "/";
        shell.launcher.providers.calculator.prefix = "calc";
        shell.launcher.providers.calculator.global = true;
        shell.launcher.providers.emoji.prefix = "emo";
        shell.launcher.providers.emoji.global = false;
        shell.launcher.providers.session.prefix = "session";
        shell.launcher.providers.session.global = false;
        shell.launcher.providers.wallpaper.prefix = "wall";
        shell.launcher.providers.wallpaper.global = false;
        shell.launcher.providers.windows.prefix = "win";
        shell.launcher.providers.windows.global = false;

        ### ===== Control Center =====
        ## ===== General =====
        shell.panel.control_center_placement = "attached";
        shell.panel.open_near_click_control_center = false;
        control_center.width = 700;
        control_center.sidebar = "compact";
        control_center.sidebar_section = "compact";
        control_center.shortcuts = lib.map (x: { type = x; }) [
          "wifi"
          "bluetooth"
          "caffeine"
          "nightlight"
          "notification"
          "power_profile"
        ];
        control_center.show_shortcut_labels = true;
        control_center.hidden_tabs = [
          "media"
        ];

        ### ===== Notifications =====
        ## ===== General =====
        notification.enable_daemon = true;
        notification.show_app_name = true;
        notification.show_actions = true;
        notification.collapse_on_dismiss = true;

        ## ===== Toasts =====
        notification.layer = "top";
        notification.position = "top_right";
        notification.scale = 1.0;
        notification.offset_x = 20;
        notification.offset_y = 8;
        notification.background_opacity = 0.97;
        notification.border = true;
        notification.monitors = [];

        ## ===== History =====
        notification.history_retention_hours = 0;

        ### ===== Shell =====
        ## ===== General =====
        # shell.avatar_path = "";
        shell.time_format = "{:%H:%M}";
        shell.date_format = "%A, %x";
        shell.launch_apps_as_systemd_services = true;

        ### ===== Location =====
        ## ===== Location =====
        location.auto_locate = true;
        # location.custom_schedule = false;
        # location.sunset = "20:30";
        # location.sunrise = "07:30";

        ## ===== Weather =====
        weather.enabled = true;
        shell.show_location = true;
        weather.unit = "metric";
        weather.effects = false;
        weather.refresh_minutes = 30;

        ## ===== Night Light =====
        nightlight.enabled = false;

        ### ===== Bar: default =====
        ## ===== General =====
        bar.default.enabled = true;
        bar.default.position = "top";
        bar.default.auto_hide = false;
        bar.default.reserve_space = true;
        bar.default.layer = "top";

        ## ===== Layout =====
        bar.default.thickness = 32;
        bar.default.scale = 1.0;
        bar.default.margin_ends = 4;
        bar.default.margin_edge = 0;
        bar.default.margin_opposite_edge = 0;
        bar.default.padding = 16;
        bar.default.panel_overlap = 2;

        ## ===== Shape =====
        bar.default.radius = 8;
        bar.default.radius_top_left = 8;
        bar.default.radius_top_right = 8;
        bar.default.radius_bottom_left = 8;
        bar.default.radius_bottom_right = 8;
        bar.default.concave_edge_corners = true;
        bar.default.border = "outline";
        bar.default.border_width = 0.0;

        ## ===== Effects =====
        bar.default.background_opacity = 0.8;
        bar.default.shadow = true;
        bar.default.contact_shadow = false;

        ## ===== Widgets =====
        bar.default.font_family = ""; # "" == inherit from shell.font_family
        bar.default.font_weight = 500;
        bar.default.widget_spacing = 8;
        # bar.default.color = "";
        # bar.default.icon_color = "";
        bar.default.hover_highlight = true;

        ## ===== Capsules =====
        bar.default.capsule = false; # TODO: I like this, maybe turn it on?

        ## ===== Widget List =====
        bar.default.start = [
          "workspaces"
        ];
        bar.default.center = [
          "clock"
        ];
        bar.default.end = [
          "network"
          "volume"
          "battery"
          "session"
        ];

        widget."workspaces".display = "none";
        widget."workspaces".pill_scale = 0.7;
        widget."workspaces".active_pill_size = 3.0;
        widget."workspaces".focused_color = "on_surface";
        widget."workspaces".occupied_color = "on_surface_variant";
        widget."workspaces".empty_color = "on_surface_variant";

        widget."clock".format = "{:%b %d %H:%M}";

        widget."network".show_label = false;

        widget."volume".mute_glyph = "volume-zero";
        widget."volume".show_label = false;
        widget."volume".mute_color = "on_surface";

        widget."battery".show_label = false;
      };
    };
  };
}