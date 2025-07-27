{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.nix-index;
in {
  options.my.programs.nix-index = {
    enable = lib.mkDefaultEnableOption "nix-index";
    package = lib.mkOption {
      default = pkgs.nix-index;

      type = with lib.types; package;
    };
  };

  config = lib.mkIf cfg.enable {
    my.toplevel.cachix = [ cfg.package ];

    my.persist.directories = [ "~/.cache/nix-index" ];

    programs.command-not-found.enable = lib.mkForce false;
    programs.nix-index = {
      inherit (cfg) enable package;
    };
  };
}
