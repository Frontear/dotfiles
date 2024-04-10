{ config, inputs, pkgs, ... }:
let
  hyprland-pkg = config.programs.hyprland.package;
in {
  imports = [
    inputs.hyprland.nixosModules.default

    ./programs/armcord.nix
    ./programs/light.nix
    ./programs/waybar
    ./services/greetd.nix
    ./services/pipewire.nix
  ];

  # System
  environment.persistence."/nix/persist" = {
    directories = [
      { directory = "/var/cache/tuigreet"; user = "greeter"; group = "greeter"; mode = "0755"; }
    ];
  };

  environment.systemPackages = with pkgs; [
    libinput
  ];

  programs.hyprland.enable = true;

  # User
  home-manager.users.frontear = { config, lib, ... }:
  let
    mainMod = "SUPER";
    workspaces = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ];
    directions = { l = "Left"; r = "Right"; u = "Up"; d = "Down"; };
  in {
    home.activation = {
      hyprlandLinks = lib.hm.dag.entryAfter [ "onFilesChange" ] ''
      run cd ${config.xdg.configHome}/hypr
      run cp hyprland.conf hyprland.conf.bak
      run mv hyprland.conf.bak hyprland.conf
      run chmod +w hyprland.conf

      HYPRLAND_INSTANCE_SIGNATURE=$(${hyprland-pkg}/bin/hyprctl instances | grep "instance" | sed 's/://g' | cut -d' ' -f2) run --quiet ${hyprland-pkg}/bin/hyprctl reload
      '';
    };

    xdg.configFile."hypr/hyprland.conf" = {
      text = ''
      monitor =, preferred, auto, 1.5

      env = GDK_BACKEND,wayland,x11
      env = QT_QPA_PLATFORM,wayland;xcb
      env = SDL_VIDEODRIVER,wayland
      env = CLUTTER_BACKEND,wayland

      env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      # env = QT_QPA_PLATFORMTHEME,qt6ct

      env = _JAVA_AWT_WM_NONREPARENTING,1

      exec-once = ${pkgs.waybar}/bin/waybar

      general {
        sensitivity = 1.0
        border_size = 2
        no_border_on_floating = false
        gaps_in = 2
        gaps_out = 4
        gaps_workspaces = 0
        col.inactive_border = rgba(00000000) rgba(88888888) rgba(bbbbbb88) rgba(88888888) rgba(00000000) 30deg
        col.active_border = rgba(00000000) rgba(ff574eff) rgba(ffbecdff) rgba(ff574eff) rgba(00000000) 30deg
        # col.nogroup_border
        # col.nogroup_border_active
        cursor_inactive_timeout = 15
        layout = dwindle
        no_cursor_warps = false
        no_focus_fallback = false
        apply_sens_to_raw = false
        resize_on_border = false
        # extend_border_grab_area
        # hover_icon_on_border
        allow_tearing = false
        resize_corner = 0
      }

      decoration {
        rounding = 8
        active_opacity = 1.0
        inactive_opacity = 0.8
        fullscreen_opacity = 1.0
        drop_shadow = false
        # shadow_range
        # shadow_render_power
        # shadow_ignore_window
        # col.shadow
        # col.shadow_inactive
        # shadow_offset
        # shadow_scale
        dim_inactive = true
        dim_strength = 0.1
        # dim_special
        # dim_around
        # screen_shader

        blur {
          enabled = false
          size = 4
          passes = 1
          ignore_opacity = false
          new_optimizations = true
          xray = true
          # noise
          # contrast
          # brightness
          # vibrancy
          # vibrancy_darkness
          special = false
          popups = false
          # popups_ignorealpha
        }
      }

      animations {
        enabled = true
        first_launch_animation = true

        # TODO: one day
      }

      input {
        # kb_model
        kb_layout = us
        # kb_variant
        # kb_options
        # kb_rules
        # kb_file
        numlock_by_default = false
        resolve_binds_by_sym = false
        repeat_rate = 25
        repeat_delay = 500
        sensitivity = 0.0
        accel_profile = flat
        force_no_accel = false
        left_handed = false
        # scroll_point
        scroll_method = 2fg
        # scroll_button
        scroll_button_lock = true
        scroll_factor = 1.0
        natural_scroll = false
        follow_mouse = 2
        # mouse_refocus
        # float_switch_override_focus
        # special_fallthrough

        touchpad {
          disable_while_typing = true
          natural_scroll = true
          scroll_factor = 1.0
          middle_button_emulation = false
          tap_button_map = lrm
          clickfinger_behavior = false
          tap-to-click = true
          drag_lock = true
          tap-and-drag = false
        }

        # touchdevice {}

        # tablet {}
      }

      gestures {
        workspace_swipe = true
        workspace_swipe_fingers = 3
        workspace_swipe_distance = 200
        # workspace_swipe_touch
        workspace_swipe_invert = true
        workspace_swipe_min_speed_to_force = 20
        workspace_swipe_cancel_ratio = 0.3
        workspace_swipe_create_new = true
        # workspace_swipe_direction_lock
        # workspace_swipe_direction_lock_threshold
        workspace_swipe_forever = false
        workspace_swipe_numbered = false
        # workspace_swipe_use_r
      }

      # group {}

      misc {
        disable_hyprland_logo = false
        disable_splash_rendering = false
        col.splash = rgb(ffffff)
        # splash_font_family
        force_default_wallpaper = 0
        vfr = true
        vrr = 1
        mouse_move_enables_dpms = true
        key_press_enables_dpms = true
        always_follow_on_dnd = true
        layers_hog_keyboard_focus = true
        # animate_manual_resizes
        # animate_mouse_windowdragging
        disable_autoreload = false
        # enable_swallow
        # swallow_regex
        # swallow_exception_regex
        focus_on_activate = false
        # no_direct_scanout
        hide_cursor_on_touch = true
        hide_cursor_on_key_press = true
        mouse_move_focuses_monitor = truebind = SUPER, F, togglefloating
        cursor_zoom_factor = 1.0
        # cursor_zoom_rigid
        # allow_session_lock_restore
        # background_color
        # close_special_on_empty
        new_window_takes_over_fullscreen = 2
        enable_hyprcursor = true
      }

      binds {
        # pass_mouse_when_bound
        # scroll_event_delay
        workspace_back_and_forth = false
        allow_workspace_cycles = true
        workspace_center_on = 1
        focus_preferred_method = 0
        # ignore_group_lock
        # movefocus_cycles_fullscreen
        # disable_keybind_grabbing
      }

      xwayland {
        use_nearest_neighbor = true
        force_zero_scaling = true
      }

      opengl {
        nvidia_anti_flicker = true
        force_introspection = 1
      }

      debug {
        # overlay = true
        # damage_blink = true
        # disable_logs = false
        # disable_time = false
        # damage_tracking
        enable_stdout_logs = false
        # manual_crash = 1
        suppress_errors = false
        # watchdog_timeout
        # disable_scale_checks
        # error_limit
      }

      # For those right-click context menus
      windowrulev2 = opacity 1.0 override, floating:1

      bind = ${mainMod}, Return, exec, ${pkgs.kitty}/bin/kitty
      bind = ${mainMod}, BackSpace, killactive
      bind = Control Alt, Delete, exit

      bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle
      bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 0.05- --limit 1.0
      bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 0.05+ --limit 1.0
      bind = , XF86MonBrightnessDown, exec, light -U 5
      bind = , XF86MonBrightnessUp, exec, light -A 5

      bind = SUPER, E, exec, ${pkgs.wofi}/bin/wofi --show drun

      bind = SUPER, F, togglefloating

      ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (key: arg: "bind = ${mainMod}, ${arg}, movefocus, ${key}") directions)}
      ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (key: arg: "bind = ${mainMod} Shift, ${arg}, movewindow, ${key}") directions)}

      ${builtins.concatStringsSep "\n" (map (n: "bind = ${mainMod}, ${n}, workspace, ${n}") workspaces)}
      bind = ${mainMod}, 0, workspace, 10
      ${builtins.concatStringsSep "\n" (map (n: "bind = ${mainMod} Shift, ${n}, movetoworkspace, ${n}") workspaces)}
      bind = ${mainMod} Shift, 0, movetoworkspace, 10
      '';
    };
  };
}