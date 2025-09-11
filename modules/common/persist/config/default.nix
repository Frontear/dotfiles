{
  config,
  lib,
  ...
}:
let
  cfg = config.my.persist;
in {
  imports = [
    ./copy-service.nix
    ./initrd-mount-service.nix
    ./remount-service.nix
  ];

  config = lib.mkIf cfg.enable {
    # Automatically add a default sane set of directories
    # to persist on a standard system.
    my.persist = {
      directories = [
        {
          # contains persistent information about system state for services
          path = "/var/lib";
          unique = true;
        }
        {
          # logging.. fairly straightforward, you'd always want this.
          path = "/var/log";
          unique = true;
        }
      ] ++ lib.optionals config.security.sudo.enable [
        "/var/db/sudo/lectured" # preferential.
      ];

      files = [
        {
          # systemd uses this to match up system-specific data.
          path = "/etc/machine-id";
          unique = true;
        }
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
  };
}