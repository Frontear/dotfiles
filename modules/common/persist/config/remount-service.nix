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
    # Remount the persistent bind mounts as early as possible to enforce mount
    # options that could not be set during initrd. Namely, we want `x-gvfs-hide`
    # to hide our bind mounts from certain applications, but we cannot apply it
    # in the initrd since it will not exist after `switch-root`.
    #
    # These units try to fire as early as possible to prevent other services
    # from taking hold of the mounts and making them busy. There is no way to
    # attempt a synchronisation from the mount unit like how we do it in the
    # initrd, as the mount units appear transient and active from the beginning
    # due to having been setup in the initrd. That means that services which
    # `RequireMountsFor=` said mounts will fire immediately without any delay.
    # To prevent this from being an issue, we try to fire as early as possible.
    systemd.services = lib.listToAttrs (map (path: {
      name = "persist-remount-${utils.escapeSystemdPath path.dst}";
      value = {
        unitConfig = {
          DefaultDependencies = "no"; 

          Before = "local-fs-pre.target";

          # Mirrored from the mount unit, see the description below for why
          # both are needed.
          ConditionPathIsMountPoint = "${path.dst}";
          ConditionPathExists = "${path.src}";
        };

        serviceConfig = {
          Type = "oneshot";

          ExecStart = "${lib.getExe' pkgs.util-linux "mount"}"
            + " -o 'remount,x-gvfs-hide' '${path.dst}'";
        };

        requiredBy = [ "local-fs-pre.target" ];
      };
    }) cfg.toplevel);

    # Unlike what the initrd mount units do, these units do NOT exist for the
    # purpose of synchronisation with other services and their dependencies.
    # Rather, they exist to enforce `DefaultDependencies=no` and prevent systemd
    # from unmounting them during shutdown.
    #
    # Certain services, like `systemd-journald.service`, want to use `/var/log`
    # for as long as possible, and since we can't accurately determine how many
    # long lasting services will be around, we simply delay the unmount to as
    # late as possible, which ends up being past the shutdown phase, when the
    # system pivots back into the initrd and runs the post-shutdown sequence.
    #
    # Although systemd will not acknowledge these mounts if queried via its
    # `systemctl status` cli, it will correctly set `umount.target` to not
    # `Conflict=` with these mounts.
    systemd.mounts = map (path: {
      unitConfig = {
        DefaultDependencies = "no";

        # ConditionPathIsMountPoint
        # - Ensure the mount had been made by the initrd service. This can be
        #   a false positive for certain mounts that are made via other means,
        #   such as `/etc/machine-id` being mounted as a `tmpfs` by systemd.
        #   As such, a further check is needed, which is why the below is done.
        #
        # ConditionPathExists
        # - Ensure that there is an existing source that the bind mount
        #   was made from. This further proves that the initrd service
        #   definitely made this bind mount.
        ConditionPathIsMountPoint = "${path.dst}";
        ConditionPathExists = "${path.src}";
      };

      what = "${path.src}";
      where = "${path.dst}";
    }) cfg.toplevel;
  };
}
