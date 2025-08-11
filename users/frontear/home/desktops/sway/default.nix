{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;
  fs = import ./fs {
    inherit (pkgs) callPackage;
  };
in {
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;

      base16Scheme = ./base16.yaml;

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;

        size = 16;
      };

      fonts = {
        sizes = {
          terminal = 9;
        };

        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-emoji;
        };

        monospace = {
          name = "Noto Sans Mono";
          package = pkgs.noto-fonts;
        };

        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
        };

        serif = {
          name = "Noto Serif";
          package = pkgs.noto-fonts;
        };
      };

      icons = {
        enable = true;
        package = pkgs.papirus-icon-theme;

        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };

      image = ./fs/sway/backgrounds/bg_dark.jpg;
      imageScalingMode = "fit";

      polarity = "dark";
    };

    stylix.targets = {
      fontconfig.enable = true;
      font-packages.enable = true;

      dunst.enable = true;
      foot.enable = true;
      rofi.enable = true;

      gtk.enable = true;
      qt.enable = true;
    };

    my.desktops.sway.config = "${fs.sway}/config";

    programs = {
      foot.enable = true;
      foot.settings = {
        cursor = {
          style = "beam";
          unfocused-style = "none";
          blink = "yes";
          beam-thickness = "1.0";
        };

        key-bindings = {
          search-start = "Control+f";
        };

        search-bindings = {
          find-prev = "Up";
          find-next = "Down";
        };
      };

      rofi.enable = true;
      rofi.modes = lib.singleton "drun";
      rofi.theme = with config.lib.formats.rasi; {
        "*" = {
          alternate-active-background = lib.mkForce (mkLiteral "@background");
          alternate-active-foreground = lib.mkForce (mkLiteral "@blue");
          alternate-normal-background = lib.mkForce (mkLiteral "@background");
          alternate-normal-foreground = lib.mkForce (mkLiteral "@foreground");
          alternate-urgent-background = lib.mkForce (mkLiteral "@background");
          alternate-urgent-foreground = lib.mkForce (mkLiteral "@red");
        };

        "element" = {
          padding = mkLiteral "1px";
          cursor = mkLiteral "pointer";
          spacing = mkLiteral "5px";
          border = 0;
        };

        "element-text" = {
          cursor = mkLiteral "inherit";
          highlight = mkLiteral "inherit";
        };

        "element-icon" = {
          size = mkLiteral "1.0em";
          cursor = mkLiteral "inherit";
        };

        "window" = {
          padding = 5;
          border = 1;
        };

        "mainbox" = {
          padding = 0;
          border = 0;
        };

        "message" = {
          padding = mkLiteral "1px";
          border = mkLiteral "2px dash 0px 0px";
        };

        "listview" = {
          padding = mkLiteral "2px 0px 0px";
          scrollbar = true;
          spacing = mkLiteral "2px";
          fixed-height = 0;
          border = mkLiteral "2px dash 0px 0px";
        };

        "scrollbar" = {
          width = mkLiteral "4px";
          padding = 0;
          handle-width = mkLiteral "8px";
          border = 0;
        };

        "sidebar" = {
          border = mkLiteral "2px dash 0px 0px";
        };

        "button" = {
          cursor = mkLiteral "pointer";
          spacing = 0;
        };

        "num-filtered-rows" = {
          expand = false;
          text-color = mkLiteral "Gray";
        };

        "num-rows" = {
          expand = false;
          text-color = mkLiteral "Gray";
        };

        "textbox-num-sep" = {
          expand = false;
          str = "/";
          text-color = mkLiteral "Gray";
        };

        "inputbar" = {
          padding = mkLiteral "1px";
          spacing = mkLiteral "0px";
          children = [ "prompt" "textbox-prompt-colon" "entry" "overlay" "num-filtered-rows" "textbox-num-sep" "num-rows" "case-indicator" ];
        };

        "overlay" = {
          padding = mkLiteral "0px 0.2em";
          margin = mkLiteral "0px 0.2em";
        };

        "case-indicator" = {
          spacing = 0;
        };

        "entry" = {
          cursor = mkLiteral "text";
          spacing = 0;
          placeholder-color = mkLiteral "Gray";
          placeholder = "Type to filter";
        };

        "prompt" = {
          spacing = 0;
        };

        "textbox-prompt-colon" = {
          margin = mkLiteral "0px 0.3em 0.0em 0.0em";
          expand = false;
          str = ":";
        };
      };
    };

    services = {
      dunst.enable = true;
      dunst.settings = {
        global = {
          offset = "(4, 4)";
          frame_width = 2;
          gap_size = 4;
          corner_radius = 4;
        };
      };
    };

    my.programs = {
      swayidle = {
        enable = true;

        config = "${fs.swayidle}/config";
      };

      swayosd = {
        enable = true;

        style = "${fs.swayosd}/style.css";
      };

      waybar = {
        enable = true;

        config = "${fs.waybar}/config.jsonc";
        style = "${fs.waybar}/style.css";
      };
    };


    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only

      perlPackages.Apppapersway
      wl-clip-persist
    ];


    my.programs = {
      chromium = {
        enable = true;
        package = pkgs.microsoft-edge;
      };

      element.enable = true;

      legcord.enable = true;

      thunar.enable = true;
    };


    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = [ "microsoft-edge.desktop" ];
      };
    };
  };
}
