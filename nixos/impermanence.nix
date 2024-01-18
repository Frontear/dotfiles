{
  ...
}: {
  environment.persistence."/nix/persist" = {
    hideMounts = true;

    directories = [
      { directory = "/etc/NetworkManager/system-connections"; mode = "0700"; }
      { directory = "/var/cache/tuigreet"; mode = "0755"; }
    ];

    files = [
      "/var/lib/power-profiles-daemon/state.ini"
    ];

    # TODO: get users.frontear here WITHOUT needing to explicitly state username
  };

  # TODO: should /nix definition be moved here?
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=755" "noatime" "size=1G" ];
    };
  };
}
