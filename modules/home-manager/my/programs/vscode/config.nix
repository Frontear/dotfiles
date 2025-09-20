{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.vscode;
  fmt = pkgs.formats.json {};

  vscode = pkgs.callPackage ./package.nix {
    withExtensions = cfg.extensions;
    withPackages = cfg.packages;
  };
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.config/Code"
    ];

    home.packages = [
      vscode
    ];

    xdg.configFile."Code/User/settings.json".source =
      fmt.generate "settings.json" cfg.settings;
  };
}