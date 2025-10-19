{
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf pkgs.config.allowUnfree {
    # An easy catch-all to enable all possible firmware needed by the system.
    hardware.enableAllFirmware = true;
  };
}