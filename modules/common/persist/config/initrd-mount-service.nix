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
    boot.initrd.systemd.storePaths = [ pkgs.frontear.persist-make ];

    # Create the directory tree needed for the mount to materialise. This will
    # synchronise permissions at each directory, keeping them synced with the
    # permissions copied into the persistent volume.
    #
    # It enforces it's own set of `RequiresMountsFor=` dependencies to prevent
    # it from firing earlier than a parent mount. Even though it's tied to a
    # mount unit, which systemd automatically orders, the executing of this
    # unit will be in parallel to all other service units fired by their mount
    # units, causing race conditions with directory creation and subsequent
    # mounting. To prevent that, we lock the services.
    #
    # This service cannot be fired in any way other than via it's accompanying
    # mount unit. It is also a oneshot service to ensure that it fully completes
    # it's procedure before allowing the mount to fire.
    boot.initrd.systemd.services = lib.listToAttrs (map (path: {
      name = "persist-mount-${utils.escapeSystemdPath "/sysroot/${path.dst}"}";
      value = {
        unitConfig = {
          DefaultDependencies = "no";

          RequiresMountsFor = [
            (builtins.dirOf "/sysroot/${path.dst}")
            "/sysroot/${path.src}"
          ];

          ConditionPathExists = "/sysroot/${path.src}";
        };

        serviceConfig = {
          Type = "oneshot";

          ExecStart = "${lib.getExe pkgs.frontear.persist-make}"
            + " '${lib.removeSuffix path.dst "/sysroot/${path.src}"}'"
            + " '/sysroot' '${path.dst}'";
        };
      };
    }) cfg.toplevel);

    # This mount unit exists largely to synchronise the mounting of units when
    # there are multiple parent-children submounts. For example, if we want to
    # mount `/var` and `/var/log`, we need `/var` to mount first _before_ we
    # allow `/var/log` to fire. This is trivial with mount units, as systemd
    # will automatically order them one after the other.
    #
    # Before coming online, they must defer to an accompanying service to setup
    # the directory tree and synchronise permissions of all parent directories.
    boot.initrd.systemd.mounts = map (path: {
      unitConfig = {
        DefaultDependencies = "no";

        Before = "initrd.target";
        After = "persist-mount-${utils.escapeSystemdPath "/sysroot/${path.dst}"}.service";
        Requires = "persist-mount-${utils.escapeSystemdPath "/sysroot/${path.dst}"}.service";

        ConditionPathExists = [
          "/sysroot/${path.dst}"
          "/sysroot/${path.src}"
        ];
      };

      what = "/sysroot/${path.src}";
      where = "/sysroot/${path.dst}";
      options = "bind";

      requiredBy = [ "initrd.target" ];
    }) cfg.toplevel;
  };
}
