# TODO: information about mounts here
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  is-impermanent = config.impermanence.enable;
in {
  fileSystems."/" = {
    device = (if is-impermanent then "none" else "/dev/disk/by-label/root");
    fsType = (if is-impermanent then "tmpfs" else "btrfs");
    options = (if is-impermanent then [ "mode=755" "noatime" "size=1G" ] else [ "compress=zstd" ]);
  };

  fileSystems."/archive" = {
    device = "/dev/disk/by-label/archive";
    fsType = "btrfs";
    options = [ "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [ "noatime" ];
  };

  fileSystems."/nix" = mkIf is-impermanent {
    device = "/dev/disk/by-label/nix";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };
}
