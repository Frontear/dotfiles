{
  imports = [
    ./mounts.nix
    ./power-savings
  ];

  config = {
    services = {
      fwupd.enable = true;
      thermald.enable = true;
    };
  };
}