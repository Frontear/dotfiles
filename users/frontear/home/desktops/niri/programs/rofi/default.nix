{
  config,
  lib,
  ...
}:
let
  cfg = config.my.desktops.niri;

  inherit (config.lib.formats.rasi) mkLiteral;
in {
  config = lib.mkIf cfg.enable {
    stylix.targets.rofi.enable = true;

    programs.rofi = {
      enable = true;

      modes = [
        "drun"
      ];

      theme = {
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

      # Change some Stylix defaults
      theme."*" = {
        alternate-active-background = lib.mkForce (mkLiteral "@background");
        alternate-active-foreground = lib.mkForce (mkLiteral "@blue");
        alternate-normal-background = lib.mkForce (mkLiteral "@background");
        alternate-normal-foreground = lib.mkForce (mkLiteral "@foreground");
        alternate-urgent-background = lib.mkForce (mkLiteral "@background");
        alternate-urgent-foreground = lib.mkForce (mkLiteral "@red");
      };
    };
  };
}