{
  imports = [
    ./mounts.nix
    ./power-savings
  ];

  config = {
    services = {
      fwupd.enable = true;
      thermald.enable = true;

      # Using this to log in will not unlock the default keyring.
      # The "simple" fix is to just use the password for logging in,
      # and use fingerprint scanning for everything else.
      #
      # see: https://gitlab.gnome.org/GNOME/gdm/-/issues/613
      fprintd.enable = true;
    };
  };
}