inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in {
  imports = [
    (import ./channel-compat.nix inputs)
    ./nix-settings.nix
    ./nixpkgs-config.nix
  ];

  config = mkIf config.nix.enable {
    nix.package = pkgs.nixVersions.git;
  };
}
