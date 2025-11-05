{
  config,
  lib,
  pkgs,
  ...
}:
# TODO: assumes tigerlake CPU/GPU, assumes i915 kernel module
let
  usingFacter = config.facter.reportPath != null;

  hasIntelGpu =
    lib.any (x: x.driver == "i915") config.facter.report.hardware.graphics_card;
in {
  config = lib.mkIf (usingFacter && hasIntelGpu) {
    boot.kernelParams = [ "i915.enable_guc=3" ];

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };
}