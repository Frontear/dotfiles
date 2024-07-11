{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.networking.networkmanager.enable {
    networking.stevenblack.enable = true;
    networking.stevenblack.block = [ "fakenews" "gambling" "porn" ];
  };
}