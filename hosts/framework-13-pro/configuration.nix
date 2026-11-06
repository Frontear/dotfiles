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
    services = {
      # NTP daemon that's more suitable for laptops.
      #
      # see: https://discourse.nixos.org/t/why-are-we-using-systemd-timesyncd-by-default/74052
      chrony.enable = true;
    };
  };
}