{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.my.system.network;
in {
  config = mkIf cfg.enable {
    networking.stevenblack.enable = true;
    networking.stevenblack.block = [ "fakenews" "gambling" "porn" ];
  };
}