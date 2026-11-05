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
    # Use the latest xanmod kernel, mainly for the Clear Linux patches
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    services = {
      # NTP daemon that's more suitable for laptops.
      #
      # see: https://discourse.nixos.org/t/why-are-we-using-systemd-timesyncd-by-default/74052
      chrony.enable = true;
    };
  };
}