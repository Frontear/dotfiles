{
  config,
  lib,
  pkgs,
  ...
}:
{
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

  config = lib.mkIf config.my.programs.libreoffice.enable {
    fonts.fontconfig.enable = lib.mkDefault true;

    home.packages = [
      config.my.programs.libreoffice.package
      pkgs.hunspell
    ] ++
    config.my.programs.libreoffice.dictionaries ++
    config.my.programs.libreoffice.fonts;
  };
}