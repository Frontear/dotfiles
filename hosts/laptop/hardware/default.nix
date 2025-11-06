{
  imports = [
    ./mounts.nix
    ./power-savings
  ];

  config = {
    services = {
      thermald.enable = true;

      fprintd.enable = true;
    };
  };
}