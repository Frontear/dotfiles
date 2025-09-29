{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.eza;
in {
  config = lib.mkMerge [
    { programs.eza.enable = lib.mkDefault true; }

    (lib.mkIf cfg.enable {
      fonts.fontconfig.enable =  lib.mkDefault true;

      programs.eza = {
        extraOptions = [
          "--git"
          "--group"
          "--group-directories-first"
          "--icons"
          "--header"
          "--octal-permissions"
        ];
      };
    })
  ];
}