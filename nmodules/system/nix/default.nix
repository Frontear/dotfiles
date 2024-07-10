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
    ./channel-compat.nix
    ./nix-settings.nix
    ./nixpkgs-config.nix
  ];

  config = mkIf config.nix.enable {
    nix.package = pkgs.nixVersions.git;
  };
}
