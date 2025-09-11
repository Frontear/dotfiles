{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.eza;
in {
  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = lib.mkDefault true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only
    ];


    programs.eza = {
      inherit (cfg)
        enable
        package
        ;

      extraOptions = [
        "--git"
        "--group"
        "--group-directories-first"
        "--icons"
        "--header"
        "--octal-permissions"
      ];
    };
  };
}