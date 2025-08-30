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
    # Perform a possibly mostly safe copy of file contents as they are
    # found during the shutdown phase of the system.
    #
    # There is no truly safe way to perform this without losing some minimal
    # amount of data during the copy, especially for services that refuse to
    # let their fd's go. We cannot reasonably do anything at this stage, so
    # we instead opt to perform a one-off copy to obtain the initial set of
    # files from whatever we wanted to persist.
    #
    # The expectation here is that this directory won't be too big given the
    # root is mostly expected to be a tmpfs, and even if the files are big
    # and the copy takes a long time, we can justify it by remembering that
    # this copy won't happen again. It's a one-off service to obtain the bare
    # minimum level of directories (mostly for the permissions) so that a
    # reasonable directory tree is produced in the persistent location.
    systemd.services = lib.listToAttrs (map (path: {
      name = "persist-copy-${utils.escapeSystemdPath path.dst}";
      value = {
        unitConfig = {
          DefaultDependencies = "no";

          Before = "final.target";

          ConditionPathExists = [
            "${path.dst}"
            "!${path.src}"
          ];

          RequiresMountsFor = [ "${cfg.volume}" ];
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe pkgs.frontear.persist-helper} 'copy'"
            + " '/' '${cfg.volume}' '${path.dst}'";
        };

        requiredBy = [ "final.target" ];
      };
    }) cfg.toplevel);
  };
}
