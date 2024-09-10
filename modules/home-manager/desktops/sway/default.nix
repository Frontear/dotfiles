{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
{
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

  config = lib.mkIf config.my.desktops.sway.enable (lib.mkMerge [
    ({
      assertions = [
        ({
          assertion = osConfig.my.desktops.sway.enable;
          message = "Please add my.desktops.sway.enable to your NixOS configuration.";
        })
      ];

      home.packages = (
        config.my.desktops.sway.extraPackages ++
        (lib.optional config.my.desktops.sway.programs.waybar.enable pkgs.waybar)
      );
    })
    (lib.mkIf (config.my.desktops.sway.fonts != []) {
      fonts.fontconfig.enable = lib.mkDefault true;
      home.packages = config.my.desktops.sway.fonts;
    })
    (lib.mkIf (config.my.desktops.sway.config != null) {
      xdg.configFile."sway/config".text = config.my.desktops.sway.config;
    })
    (lib.mkIf (config.my.desktops.sway.programs.waybar.enable) (lib.mkMerge [
      (lib.mkIf (config.my.desktops.sway.programs.waybar.config != null) {
        xdg.configFile."waybar/config.jsonc".text = config.my.desktops.sway.programs.waybar.config;
      })
      (lib.mkIf (config.my.desktops.sway.programs.waybar.style != null) {
        xdg.configFile."waybar/style.css".source = pkgs.runCommandLocal "waybar-style-sccs" {
          nativeBuildInputs = [ pkgs.sassc ];
        } ''
          echo "${config.my.desktops.sway.programs.waybar.style}" | sassc --stdin $out
        '';
      })
    ]))
  ]);
}
