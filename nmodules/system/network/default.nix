{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.network;
in {
  imports = lib.importsRecursive ./. (x: x != "default.nix");

  options.my.system.network.enable = mkEnableOption "network";

  config = mkIf cfg.enable {
    networking.networkmanager.enable = true;
    my.system.persist.directories = [ "/etc/NetworkManager" ];
  };
}
