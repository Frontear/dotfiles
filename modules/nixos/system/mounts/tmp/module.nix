{
  config,
  lib,
  ...
}:
let
  cfg = config.my.mounts.tmp;
in {
  options.my.mounts.tmp = {
    enableTmpfs = lib.mkDefaultEnableOption "swap.enableTmpfs";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enableTmpfs {
      # Use tmpfs for /tmp as it's just easier to use.
      # Not using this means that cleaning on boot can
      # take a few seconds, which is wasteful.
      boot.tmp.useTmpfs = true;
    })
  ];
}
