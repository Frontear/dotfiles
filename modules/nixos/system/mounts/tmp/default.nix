{
  config,
  lib,
  ...
}:
let
  cfg = config.my.mounts.tmp;
in {
  options.my.mounts.tmp = {
    enableTmpfs = lib.mkEnableOption "swap.enableTmpfs" // { default = true; };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableTmpfs {
      # Force the Nix builder into a sane TMPDIR
      # TODO: move my.persist outta here?
      my.persist.directories = [ "/var/tmp" ];
      systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

      # Use tmpfs for /tmp as it's just easier to use.
      # Not using this means that cleaning on boot can
      # take a few seconds, which is wasteful.
      boot.tmp.useTmpfs = true;
    })
  ];
}
