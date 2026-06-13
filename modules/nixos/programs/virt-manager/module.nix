{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.virt-manager;
in {
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;

      # Enable the ability to share a folder with a guest.
      qemu.vhostUserPackages = with pkgs; [
        virtiofsd
      ];
    };

    # Disable stevenblack blocklist, as some of the host entries
    # cause erroneus faults in `dnsmasq` due to an upstream bug
    # between `dnsmasq` and `glibc`. Replacing long entries and/or
    # removing specific entries is insufficient, and recompiling
    # `dnsmasq` across all dependents is impossible, so this is the
    # best fix.
    #
    # TODO: remove when the relevant PR is merged.
    #
    # see: https://github.com/NixOS/nixpkgs/issues/525573
    # see: https://github.com/NixOS/nixpkgs/pull/528905
    networking.stevenblack.enable = lib.mkForce false;
  };
}