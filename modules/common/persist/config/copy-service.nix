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
    # Perform a late copy of contents into the persist as a one-off service.
    # This service attempts to orient itself after most compliant services are
    # shutdown (via `shutdown.target`), to ensure that copying can capture as
    # much as possible. For non-compliant services, this will possibly lose
    # some data, but it will be able to synchronise permissions, since that
    # is an extremely fast operation.
    #
    # The primary purpose of this service is to create a base-line directory
    # structure in the persistent volume with permissions copied over. This is
    # then used in the next boot to correctly synchronise permissions and create
    # the bind mounts. Copying data is a secondary objective to salvage as much
    # as possible for the next boot.
    systemd.services = lib.listToAttrs (map (path: {
      name = "persist-copy-${utils.escapeSystemdPath path.dst}";
      value = {
        unitConfig = {
          DefaultDependencies = "no";

          After = "shutdown.target";
          Before = "final.target";

          RequiresMountsFor = "${path.src}";

          ConditionPathExists = [
            "${path.dst}"
            "!${path.src}"
          ];
        };

        serviceConfig = {
          Type = "oneshot";

          ExecStart = [
            ("${lib.getExe pkgs.frontear.persist-make}"
              + " '/' '${lib.removeSuffix path.dst path.src}' '${path.dst}'")
            ("${lib.getExe' pkgs.coreutils "cp"}"
              + " '--archive' '${path.dst}' '${path.src}'"
            )
          ];
        };

        requiredBy = [ "final.target" ];
      };
    }) cfg.toplevel);
  };
}
