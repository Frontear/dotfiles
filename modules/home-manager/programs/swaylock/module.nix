{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.swaylock;

  conf = config.xdg.configFile."swaylock/config".source;
in {
  config = lib.mkIf cfg.enable {
    programs.swaylock = {
      package = pkgs.callPackage ./package.nix {
        swaylock = pkgs.swaylock-effects;

        extraArgs = "-C ${conf}";
      };

      settings = lib.mkIf config.stylix.enable {
        font = config.stylix.fonts.sansSerif.name;
      };
    };

    xdg.configFile."swaylock/config".enable = lib.mkForce false;
  };
}
