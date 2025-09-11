{
  self,
  inputs,
  ...
}:
{
  flake = {
    lib = inputs.nixpkgs.lib.extend (import ../../lib { inherit self; });
  };
}