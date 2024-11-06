{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.tldr;
  fmt = pkgs.formats.toml {};
in {
  options = {
    my.programs.tldr = {
      enable = lib.mkDefaultEnableOption "tldr";
      package = lib.mkPackageOption pkgs "tlrc" {};

      settings = lib.mkOption {
        default = {};

        type = fmt.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    my.programs.tldr.settings = {
      cache.dir = "${config.xdg.cacheHome}/tlrc";
    };

    my.persist.directories = [
      "~/.cache/tlrc"
    ];

    home.packages = [ cfg.package ];

    xdg.configFile."tlrc/config.toml".source = fmt.generate "tlrc-config.toml" cfg.settings;
  };
}
