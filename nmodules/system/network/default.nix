{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./cloudflare-dns.nix
    ./hosts-list.nix
    ./power-saving.nix
  ];
}
