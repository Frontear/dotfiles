{
  lib,

  facterGuard,
  ...
}:
let
  self' = {
    isTigerlake = config: facterGuard config &&
      (config.facter.report.hardware.graphics_card
      |> lib.any (x:
        # Intel Corporation
        x.vendor.hex == "8086"
        # TigerLake-LP GT2
        && x.device.hex == "9a49"
      ));
  };
in
  self'