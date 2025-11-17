{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware
    ./specialisations
  ];

  config = {
    my.defaults.enable = true;

    # Use the latest xanmod kernel, mainly for the Clear Linux patches
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    services = {
      # NTP daemon that's more suitable for laptops
      chrony.enable = true;

      # Use the fingerprint sensor on my laptop.
      #
      # TODO: detect from `facter.json`
      fprintd.enable = true;
    };
  };
}