{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkForce mkIf;
in {
  options.my.system.mounts.tmp.enable = mkEnableOption "tmp" // {
    description = ''
      Whether to enable tmp.

      Note that disabling this **doesn't** imply that /tmp is non-existent,
      it will simply be auto-mounted by systemd as a tmpfs partition, something
      which will end up being an issue on Nix systems.
    '';
    default = true;
  };

  config = mkIf config.my.system.mounts.tmp.enable {
    # Ensure /tmp is cleaned on boot and that it is not mounted
    # as a tmpfs, as this can fail on large nix builds.
    boot.tmp = {
      cleanOnBoot = true;
      useTmpfs = mkForce false;
    };

    # Link /tmp to persistence device, so it doesn't
    # end up on the tmpfs root.
    my.persist.directories = [
      { path = "/tmp"; mode = "777"; }
    ];
  };
}