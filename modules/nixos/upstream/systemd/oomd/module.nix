{
  config,
  lib,
  ...
}:
let
  cfg = config.systemd.oomd;
in {
  config = lib.mkIf cfg.enable {
    # TODO: remove when my pull request gets merged and lands in unstable.
    #
    # see: https://github.com/NixOS/nixpkgs/pull/438995
    systemd.services.systemd-oomd.after = [ "swap.target" ];
  };
}
