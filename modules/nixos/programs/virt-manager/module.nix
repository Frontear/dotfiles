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
  };
}