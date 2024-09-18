{
  self,
  lib,
  ...
}:
{
  # Cachix linkFarm's are special, they are handled independently here.
  flake.packages = import ./cachix { inherit self lib; };
}
