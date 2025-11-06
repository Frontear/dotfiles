{
  facterGuard,
  ...
}:
let
  self' = {
    isPhysical = config: facterGuard config &&
      (config.facter.report.virtualisation == "none");
  };
in
  self'