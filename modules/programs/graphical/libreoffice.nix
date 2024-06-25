{ ... }: ({ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.graphical;
in {
  config = mkIf cfg.enable {
    home-manager.users.frontear = { pkgs, ... }: {
      fonts.fontconfig.enable = true;

      home.packages = with pkgs; [
        corefonts

        libreoffice-qt

        hunspell
        hunspellDicts.en_CA
        hunspellDicts.en_US
      ];
    };
  };
})
