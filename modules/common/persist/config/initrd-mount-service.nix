{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.my.persist;
in {
  config = lib.mkIf cfg.enable {
    # Create services that will attempt to mount our units in parallel
    # from within the initrd.
    #
    # The motivation behind performing this in the initrd is to avoid
    # conflicts with files that needed to exist earlier. For example,
    # if we want to persist `/var/log` but do so too late, the journal
    # will already have created this directory and written to it. Any
    # attempts at a bind here will result in a loss of data, or race
    # conditions between attempting to copy and bind on top. This is
    # just too messy.
    #
    # Furthermore, at a conceptual level, one could think of these bind
    # mounts like real files that were brought up thanks to the sysroot
    # mount. After all, on a non-ephemeral root system, these files would
    # be brought with the root, so why not make it almost seem like that?
    boot.initrd.systemd.storePaths = [ pkgs.frontear.persist-helper ];
    boot.initrd.systemd.services = lib.listToAttrs (map (path: {
      name = "persist-mount-${utils.escapeSystemdPath path.dst}";
      value = {
        unitConfig = {
          DefaultDependencies = "no";

          After = "sysroot.mount";
          Before = "initrd-root-fs.target";

          ConditionPathExists = [
            "/sysroot/${path.src}"
            "!/sysroot/${path.dst}"
          ];

          RequiresMountsFor = [ "/sysroot/${cfg.volume}" ];
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.frontear.persist-helper} 'mount'"
            + " '/sysroot/${cfg.volume}' '/sysroot' '${path.dst}'";
        };

        requiredBy = [ "initrd-root-fs.target" ];
      };
    }) cfg.toplevel);
  };
}
