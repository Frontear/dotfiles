{
  lib,
  pkgs,
  ...
}:
{
  config.hardware = {
    enableAllFirmware = pkgs.config.allowUnfree;
    enableRedistributableFirmware = lib.mkForce true;

    cpu = lib.genAttrs [ "amd" "intel" ] (_: {
      updateMicrocode = true;
    });
  };
}