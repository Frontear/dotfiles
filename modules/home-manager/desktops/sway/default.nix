{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktops.sway;
in {
  options.my.desktops.sway = {
    enable = lib.mkEnableOption "sway";

    config = lib.mkOption {
      default = null;
      description = ''
        Sway configuration options.
      '';

      type = with lib.types; nullOr lines;
    };

    extraPackages = lib.mkOption {
      default = [];
      description = ''
        Extra packages to install with sway.
      '';

      type = with lib.types; listOf package;
    };

    fonts = lib.mkOption {
      default = [];
      description = ''
        Fonts to install with Sway.
      '';

      type = with lib.types; listOf package;
    };

    programs = {
      waybar = {
        enable = lib.mkEnableOption "sway.programs.waybar" // { default = true; };
        package = lib.mkOption {
          default = pkgs.waybar;
          defaultText = "pkgs.waybar";
          description = ''
            The waybar package to use.
          '';

          type = with lib.types; package;
        };

        config = lib.mkOption {
          default = null;
          description = ''
            Waybar configuration options.
          '';

          type = with lib.types; nullOr lines;
        };

        style = lib.mkOption {
          default = null;
          description = ''
            Waybar stylesheet options, processed through scss.
          '';

          type = with lib.types; nullOr lines;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      assertions = [
        ({
          assertion = osConfig.my.desktops.sway.enable;
          message = "Please add my.desktops.sway.enable to your NixOS configuration.";
        })
      ];

      home.packages = (
        cfg.extraPackages ++
        (lib.optional cfg.programs.waybar.enable cfg.programs.waybar.package)
      );
    })
    (lib.mkIf (cfg.fonts != []) {
      fonts.fontconfig.enable = lib.mkDefault true;
      home.packages = cfg.fonts;
    })
    (lib.mkIf (cfg.config != null) {
      xdg.configFile."sway/config".text = cfg.config;
    })
    (lib.mkIf (cfg.programs.waybar.enable) (lib.mkMerge [
      (lib.mkIf (cfg.programs.waybar.config != null) {
        xdg.configFile."waybar/config.jsonc".text = cfg.programs.waybar.config;
      })
      (lib.mkIf (cfg.programs.waybar.style != null) {
        xdg.configFile."waybar/style.css".source = pkgs.runCommandLocal "waybar-style-sccs" {
          nativeBuildInputs = [ pkgs.sassc ];
        } ''
          echo '${cfg.programs.waybar.style}' | sassc --stdin $out
        '';
      })
    ]))
  ]);
}
