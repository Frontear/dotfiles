{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) any;
  inherit (lib) mapAttrsToList mkEnableOption mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.libreoffice = {
      enable = mkEnableOption "libreoffice";
      package = mkOption {
        default = pkgs.libreoffice-qt;

        type = types.package;
        internal = true;
        readOnly = true;
      };
    };

    config = mkIf config.programs.libreoffice.enable {
      packages = [
        config.programs.libreoffice.package
      ] ++ (with pkgs; [
        hunspell
      ]) ++ (with pkgs.hunspellDicts; [
        en_CA
        en_US
      ]);
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };

  config.fonts.packages = mkIf (any (cfg: cfg.enable) (mapAttrsToList (_: v: v.programs.libreoffice) config.my.users)) [
    pkgs.corefonts
  ];
}