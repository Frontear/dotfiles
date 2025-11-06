{
  config,
  lib,
  pkgs,
  ...
}:
let
  validGPU = lib.facter.gpu.isTigerlake config;
in {
  # TODO: way too opinionated. This is unsuitable for here and should be dropped
  # if/when there is a proper upstream module for Intel graphics.
  config = lib.mkIf validGPU {
    boot.kernelParams = [ "i915.enable_guc=3" ];

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };
}