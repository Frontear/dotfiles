{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.noctalia;
  fmt = pkgs.formats.toml { };
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    # Set some default based on Stylix.
    # Mostly copied from the Stylix module for Noctalia.
    #
    # see: https://github.com/nix-community/stylix/blob/1e6ccadeda179d96728b4a9f20fc9d4dcf6b6059/modules/noctalia/hm.nix
    my.programs.noctalia = lib.mkIf config.stylix.enable {
      settings = {
        theme = {
          mode = config.stylix.polarity;
          source = "custom";
          custom_palette = "stylix";
        };

        wallpaper = {
          enabled = true;

          fill_mode = config.stylix.imageScalingMode;

          # TODO: does not seem to apply. The stateful data in ~/.local/state
          # gets created with the Noctalia default, even if I delete the state.
          default = {
            path = config.stylix.image;
          };
        };

        shell = {
          font_family = config.stylix.fonts.sansSerif.name;
        };
      };
    };

    my.persist.directories = [{
      path = "~/.local/state/noctalia";
      unique = true;
    }];

    systemd.user.services.noctalia = {
      Unit = {
        PartOf = [ config.wayland.systemd.target ];
        After = [ config.wayland.systemd.target ];

        X-Restart-Triggers = lib.optional (cfg.settings != {})
          "${config.xdg.configFile."noctalia/config.toml".source}";
      };

      Service = {
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ config.wayland.systemd.target ];
      };
    };

    xdg.configFile."noctalia/config.toml" =
      lib.mkIf (cfg.settings != {}) {
        source = let
          toml = fmt.generate "config.toml" cfg.settings;
        in pkgs.runCommand "config-validate" {} ''
          ${lib.getExe cfg.package} config validate ${toml}
          cp ${toml} $out
        '';
      };

    # Snippet copied from Stylix's module.
    #
    # see: https://github.com/nix-community/stylix/blob/1e6ccadeda179d96728b4a9f20fc9d4dcf6b6059/modules/noctalia/hm.nix
    xdg.configFile."noctalia/palettes/stylix.json" = lib.mkIf config.stylix.enable {
      source = (pkgs.formats.json { }).generate "stylix-palette.json" {
        dark = with config.lib.stylix.colors.withHashtag; {
          mPrimary = base0D;
          mOnPrimary = base00;
          mSecondary = base0E;
          mOnSecondary = base00;
          mTertiary = base0C;
          mOnTertiary = base00;
          mError = base08;
          mOnError = base00;
          mSurface = base00;
          mOnSurface = base05;
          mHover = base0C;
          mOnHover = base00;
          mSurfaceVariant = base01;
          mOnSurfaceVariant = base04;
          mOutline = base03;
          mShadow = base00;

          terminal = {
            foreground = base05;
            background = base00;
            cursor = base05;
            cursorText = base00;
            selectionFg = base05;
            selectionBg = base02;
            normal = {
              black = base00;
              red = base08;
              green = base0B;
              yellow = base0A;
              blue = base0D;
              magenta = base0E;
              cyan = base0C;
              white = base05;
            };
            bright = {
              black = base03;
              red = base08;
              green = base0B;
              yellow = base0A;
              blue = base0D;
              magenta = base0E;
              cyan = base0C;
              white = base07;
            };
          };
        };
      };
    };
  };
}