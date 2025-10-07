{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.vscode;
  fmt = pkgs.formats.json {};
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.config/Code"
    ];

    home.packages = [
      cfg.package
    ];

    xdg.configFile."Code/User/settings.json".source =
      fmt.generate "settings.json" cfg.settings;
  };
}