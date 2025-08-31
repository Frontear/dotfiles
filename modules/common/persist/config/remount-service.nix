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
    # Remount the persistent mounts extremely early in the system's boot to
    # append mount options that would otherwise be lost during the initrd
    # transition via `switch-root`.
    #
    # Most mount options survive the transition from initrd to real system,
    # however some special mount options are treated as comments and are not
    # processed by `mount`. These are prefixed with `X-*` or `x-*`, the former
    # being system-level, and the latter being user-level. These options are
    # lost during the transition as they aren't important to the mount itself,
    # and only serve to "mark" them in some form for other applications to make
    # use of. One notable example is `x-gvfs-hide`, which certain applications
    # use to determine whether to show or hide a mount in their interface.
    #
    # In order to bring these options back, it's essential to perform a remount.
    # We have to do this early on to avoid interrupting applications that may
    # be working with the paths exposed by the persistent mounts. This approach
    # is identical to how systemd handles mount options for other initrd mounts,
    # such as `/`, `/usr`, and the virtual file systems like `/proc` and `/dev`.
    systemd.services = lib.listToAttrs (map (path: {
      name = "persist-remount-${utils.escapeSystemdPath path.dst}";
      value = {
        unitConfig = {
          DefaultDependencies = "no";

          Before = "local-fs-pre.target";

          ConditionPathExists = [
            "${path.dst}"
            "${path.src}"
          ];

          RequiresMountsFor = [ "${cfg.volume}" ];
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe' pkgs.util-linux "mount"}"
            + " -o remount,x-gvfs-hide '${path.dst}'";
        };

        requiredBy = [ "local-fs-pre.target" ];
      };
    }) cfg.toplevel);

    # Create a persistent mount unit to safely overtake the transient one after
    # remounting from the above service. This will prevent systemd from trying
    # to unmount the mount during the shutdown phase, delaying it's unmount
    # into the exitrd, where root `/` is brought down.
    #
    # This unit does not conflict with the transient unit produced by the call
    # to `mount` from the initrd service. It permanently remains inactive until
    # after the remount service fires, upon which systemd will recognize the
    # unit, and activate it. This disables the default dependencies of a mount
    # unit, which is a safe operation to do as we strictly control the lifetime
    # of our mounts, from the initrd and until the shutdown. Doing this will
    # intertwine the lifetime of our persist mounts with our root `/`.
    systemd.mounts = map (path: {
      unitConfig = {
        DefaultDependencies = "no";
      };

      what = "${path.src}";
      where = "${path.dst}";
    }) cfg.toplevel;
  };
}
