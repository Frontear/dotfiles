{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.network;
in {
  imports = [
    ./cloudflare-dns.nix
    ./hosts-list.nix
    ./power-saving.nix
  ];

  options.my.system.network.enable = mkEnableOption "network";

  config = mkIf cfg.enable {
    networking.networkmanager.enable = true;
  };
}
