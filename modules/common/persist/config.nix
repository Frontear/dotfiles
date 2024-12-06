{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.my.persist;

  persist-helper = lib.getExe (pkgs.callPackage ./package {});
in {
  config = lib.mkIf cfg.enable {
    # Automatically add a default sane set of directories
    # to persist on a standard system.
    my.persist = {
      directories = [
        "/var/lib" # contains persistent information about system state for services
        "/var/log" # logging.. fairly straightforward, you'd always want this.
      ] ++ lib.optionals config.security.sudo.enable [
        "/var/db/sudo/lectured" # preferential.
      ];

      files = [
        "/etc/machine-id" # systemd uses this to match up system-specific data.
      ];
    };

    # Kill the `systemd-machine-id-commit` service, introduced in systemd 256.7.
    #
    # This service detects when `/etc/machine-id` seems to be in danger of being
    # lost, and attempts to persist it to a writable medium. I don't know the
    # details of what it considers "a writable medium", however we do know that
    # our setup causes this unit to fire.
    #
    # In our case, choosing to persist `/etc/machine-id` (default behaviour)
    # causes this service to think our file is at risk of disappearing, and as
    # a result, tries to persist it. However, it cannot determine a place to
    # save it, which causes the service to fail.
    #
    # This doesn't matter at all for our setup because we have the confidence
    # in knowing the file is safe. If for some reason it's not, then that was
    # a concious decision by the user and they can handle the problems with it.
    boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

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
    #
    # Note that there isn't a hard dependency on when these must finish.
    # This is because there's no immediate importance to force them to finish
    # fast since nothing in the initrd (to my knowledge) should cause problems
    # for these mounts.
    boot.initrd.systemd.storePaths = [ persist-helper ];
    boot.initrd.systemd.services = lib.listToAttrs (map (path: {
      name = "persist-mount-${utils.escapeSystemdPath path}";
      value = {
        unitConfig = {
          DefaultDependencies = "no";

          After = "sysroot.mount";
          Before = "initrd-root-fs.target";

          ConditionPathExists = [
            "/sysroot/${cfg.volume}/${path}"
            "!/sysroot/${path}"
          ];

          RequiresMountsFor = [ "/sysroot/${cfg.volume}" ];
        };

        serviceConfig = {
          ExecStart = "${persist-helper} 'mount'"
            + " '/sysroot/${cfg.volume}' '/sysroot' '${path}'";
        };

        requiredBy = [ "initrd-root-fs.target" ];
      };
    }) cfg.toplevel);

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
      name = "persist-copy-${utils.escapeSystemdPath path}";
      value = {
        unitConfig = {
          DefaultDependencies = "no";

          Before = "final.target";

          ConditionPathExists = [
            "${path}"
            "!${cfg.volume}/${path}"
          ];

          RequiresMountsFor = [ "${cfg.volume}" ];
        };

        serviceConfig = {
          ExecStart = "${persist-helper} 'copy' '/' '${cfg.volume}'"
            + " '${path}'";
        };

        requiredBy = [ "final.target" ];
      };
    }) cfg.toplevel);
  };
}
