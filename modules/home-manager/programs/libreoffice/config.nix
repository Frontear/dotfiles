{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.libreoffice;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.config/libreoffice"
    ];

    fonts.fontconfig.enable = lib.mkDefault true;

    home.packages = [
      cfg.package

      pkgs.corefonts

      (pkgs.hunspell.withDicts (dict: [
        dict.en_CA
        dict.en_US
      ]))
    ];
  };
}