{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.nix;
in {
  imports = [
    ./channel-compat.nix
    ./nix-settings.nix
    ./nixpkgs-config.nix
  ];

  options.my.system.nix.enable = mkEnableOption "nix";

  config = mkIf cfg.enable {
    nix.enable = true;
  };
}