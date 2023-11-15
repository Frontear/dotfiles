{ ... }:
let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  persistence_directory = "/nix/persist";

  boot_device = "/dev/disk/by-label/efi";
  boot_fsType = "vfat";

  nix_device = "/dev/disk/by-label/nix";
  nix_fsType = "ext4";
in
{
  imports = [ "${impermanence}/nixos.nix" ];

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=1G" "mode=755" ];
    };
    "/boot" = {
      device = "${boot_device}";
      fsType = "${boot_fsType}";
    };
    "/nix" = {
      device = "${nix_device}";
      fsType = "${nix_fsType}";
    };
  };

  environment.persistence."${persistence_directory}" = {
    directories = [
      "/home/frontear" # temporarily, to remove in the future

      "/etc/NetworkManager"
      "/etc/nixos"
      "/var/db/sudo/lectured"
      "/var/log"
    ];

    files = [
      "/etc/machine-id"
    ];
  };
}
