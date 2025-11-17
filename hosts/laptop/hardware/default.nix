{
  imports = [
    ./mounts.nix
    ./power-savings
  ];

  config = {
    services = {
      fprintd.enable = true;
    };
  };
}