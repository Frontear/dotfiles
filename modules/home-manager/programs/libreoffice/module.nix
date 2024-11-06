{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.libreoffice;
in {
  options.my.programs.libreoffice = {
    enable = lib.mkEnableOption "libreoffice";
    package = lib.mkOption {
      default = pkgs.libreoffice-fresh;
      defaultText = "pkgs.libreoffice-fresh";
      description = ''
        The libreoffice package to use.
      '';

      type = with lib.types; package;
    };

    dictionaries = lib.mkOption {
      default = [];
      description = ''
        Hunspell dictionaries installed to the user and
        accessible in LibreOffice.
      '';

      type = with lib.types; listOf (enum (lib.attrValues pkgs.hunspellDicts) // {
        description = ''
          one of pkgs.hunspellDicts.*
        '';
      });
    };

    fonts = lib.mkOption {
      default = [];
      description = ''
        Fonts that are installed to the user and
        accessible in LibreOffice.
      '';

      type = with lib.types; listOf package;
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.config/libreoffice";
      mode = "700";
    }];

    fonts.fontconfig.enable = lib.mkDefault true;

    home.packages = [
      cfg.package
      pkgs.hunspell
    ] ++
    cfg.dictionaries ++
    cfg.fonts;
  };
}
