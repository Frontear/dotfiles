{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.niri;
in {
  imports = [
    ./my
    ./programs
    ./services
    ./stylix
  ];

  config = lib.mkIf cfg.enable {
    my.desktops.niri = {
      settings = ''
        output "eDP-1" {
          scale 1.5
        }

        input {
          keyboard {
            repeat-delay 250
            repeat-rate 25
          }

          touchpad {
            accel-profile "adaptive"
            click-method "clickfinger"
            drag false
            dwt
            dwtp
            // left-handed
            // middle-emulation
            // natural-scroll
            accel-speed 0.0
            scroll-factor 1.0
            scroll-method "two-finger"
            tap
            tap-button-map "left-middle-right"
          }
        }

        screenshot-path "~/Pictures/Screenshots/%Y-%m/%Y-%m-%d_%Hh%Mm%Ss.png"
        hotkey-overlay { skip-at-startup; }

        cursor {
          xcursor-theme "${config.stylix.cursor.name}"
          xcursor-size ${toString config.stylix.cursor.size}
        }

        switch-events {
          lid-close { spawn "swaylock"; }
        }


        spawn-sh-at-startup "${lib.getExe pkgs.wl-clip-persist} --clipboard regular"
        spawn-sh-at-startup "${lib.getExe pkgs.swaybg} -i '${config.stylix.image}' -m '${config.stylix.imageScalingMode}'"


        // rounded corners always
        prefer-no-csd
        window-rule {
          geometry-corner-radius 8
          clip-to-geometry true
        }

        layout {
          // emulates inner-gap of 2, and outer-gap of 4
          gaps 2
          struts { left 2; right 2; top 2; bottom 2; }

          focus-ring { off; }

          border {
            width 2

            active-color "#ff000055"
            inactive-color "#595959aa"
          }
        }


        binds {
          XF86AudioMute allow-when-locked=true repeat=false { spawn-sh "swayosd-client --output-volume mute-toggle"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "swayosd-client --output-volume -5"; }
          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "swayosd-client --output-volume +5"; }

          XF86MonBrightnessDown allow-when-locked=true { spawn-sh "swayosd-client --brightness -5"; }
          XF86MonBrightnessUp allow-when-locked=true { spawn-sh "swayosd-client --brightness +5"; }


          Print repeat=false { screenshot; }


          Ctrl+Alt+Delete repeat=false { quit; }

          Mod+BackSpace repeat=false { close-window; }
          Mod+Return repeat=false { spawn "footclient"; }
          Mod+E repeat=false { spawn-sh "rofi -show drun -run-command 'app2unit -- {cmd}'"; }
          Mod+L repeat=false { spawn "swaylock"; }

          F11 repeat=false { fullscreen-window; }
          Mod+F repeat=false { maximize-column; }

          Mod+Tab repeat=false { toggle-overview; }

          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-or-workspace-down; }
          Mod+Up    { focus-window-or-workspace-up; }
          Mod+Right { focus-column-right; }

          Mod+Shift+Left  { move-column-left; }
          Mod+Shift+Down  { move-window-down-or-to-workspace-down; }
          Mod+Shift+Up    { move-window-up-or-to-workspace-up; }
          Mod+Shift+Right { move-column-right; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+0 { focus-workspace 10; }

          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }
          Mod+Shift+6 { move-column-to-workspace 6; }
          Mod+Shift+7 { move-column-to-workspace 7; }
          Mod+Shift+8 { move-column-to-workspace 8; }
          Mod+Shift+9 { move-column-to-workspace 9; }
          Mod+Shift+0 { move-column-to-workspace 10; }
        }
      '';
    };


    # TODO: de-duplicate fontconfig and `nerd-fonts.symbols-only` snippets
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only

      app2unit
    ];
  };
}