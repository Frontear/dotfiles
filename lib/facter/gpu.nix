{
  lib,

  facterGuard,
  ...
}:
let
  self' = {
    isIntel = config: facterGuard config &&
      (config.facter.report.hardware.graphics_card
      |> lib.any (x: x.driver == "i915"));
  };
in
  self'