{
  config,
  lib,
  ...
}:
let
  validCPU = lib.facter.cpu.isIntel config;
in {
  config = lib.mkIf validCPU {
    services.thermald.enable = true;
  };
}