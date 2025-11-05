{
  config,
  lib,
  pkgs,
  ...
}:
let
  usingFacter = config.facter.reportPath != null;

  # TODO: migrate to `xe` module once stable
  hasIntelGpu =
    lib.any (x: x.driver == "i915") config.facter.report.hardware.graphics_card;

  isTigerlake = lib.any (x:
    x.family == 6 &&
    x.model == 140
  ) config.facter.report.hardware.cpu;
in {
  config = lib.mkIf (usingFacter && hasIntelGpu && isTigerlake) {
    boot.kernelParams = [ "i915.enable_guc=3" ];

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };
}