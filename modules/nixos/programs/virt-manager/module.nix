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

      qemu = {
        swtpm.enable = true; # Emulate TPM inside of VMs.

        # Enable the ability to share a folder with a guest.
        vhostUserPackages = [
          pkgs.virtiofsd
        ];
      };
    };
  };
}