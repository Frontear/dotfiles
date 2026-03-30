{
  lib,
  pkgs,
  ...
}:
{
  config = {
    hardware = {
      enableAllFirmware = pkgs.config.allowUnfree;
      enableRedistributableFirmware = lib.mkForce true;

      cpu = lib.genAttrs [ "amd" "intel" ] (_: {
        updateMicrocode = true;
      });
    };

    # Enable NVIDIA support for installation hosts using their GPUs
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.open = true; # NOTE: only supports RTX 20+, or GTX 16+
    hardware.nvidia.modesetting.enable = true; # needed for Wayland
  };
}