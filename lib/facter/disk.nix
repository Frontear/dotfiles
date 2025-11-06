{
  lib,

  facterGuard,
  ...
}:
let
  self' = {
    isNVMe = config: facterGuard config &&
      (config.facter.report.hardware.disk
      |> lib.any (x: x.driver == "nvme"));
  };
in
  self'