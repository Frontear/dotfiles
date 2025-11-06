{
  lib,

  facterGuard,
  ...
}:
let
  self' = {
    isIntel = config: facterGuard config &&
      (config.facter.report.hardware.cpu
      |> lib.any (x: x.vendor_name == "GenuineIntel"));

    isTigerlake = config: self'.isIntel config &&
      (config.facter.report.hardware.cpu
      |> lib.any (x: x.family == 6 && x.model == 140));
  };
in
  self'