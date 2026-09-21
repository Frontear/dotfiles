{
  facterGuard,
  ...
}:
let
  self' = {
    isPhysical = config: facterGuard config &&
      (config.hardware.facter.report.virtualisation == "none");
  };
in
  self'