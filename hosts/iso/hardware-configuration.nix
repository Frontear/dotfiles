{
  config,
  lib,
  ...
}:
{
  config.hardware = {
    enableAllFirmware = config.nixpkgs.config.allowUnfree;
    enableRedistributableFirmware = lib.mkForce true;

    cpu = lib.genAttrs [ "amd" "intel" ] (_: {
      updateMicrocode = true;
    });
  };
}