{
  lib,
  ...
}:
let
  callLib = file: import file {
    inherit lib;

    # Used by all lib functions to immediately return false if this is false.
    facterGuard = config:
      config.facter.reportPath != null;
  };

  # NOTE: many of these definitions are incomplete, due to lacking hardware.
  # If at any point the definitions can be completed, consider doing so, and
  # subsequently consider upstreaming.
  self' = {
    disk = callLib ./disk.nix;
    gpu = callLib ./gpu.nix;
    machine = callLib ./machine.nix;
  };
in
  self'