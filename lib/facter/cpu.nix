{
  lib,

  facterGuard,
  ...
}:
let
  self' = {
    isIntel = config: facterGuard config &&
      (config.facter.report.hardware.cpu
      |> lib.any (x:
        x.vendor_name == "GenuineIntel"
      ));
  };
in
  self'