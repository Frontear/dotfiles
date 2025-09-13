{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.nixpkgs.config.allowUnfree {
    # An easy catch-all to enable all possible firmware needed by the system.
    hardware.enableAllFirmware = true;
  };
}