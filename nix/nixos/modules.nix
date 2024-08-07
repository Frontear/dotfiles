{
  inputs,
  ...
}:
{
  flake.nixosModules.default = (
    {
      lib,
      ...
    }:
    {
      imports = lib.importsRecursive ../../modules (x: x == "default.nix");

      config._module.args = { inherit inputs; };
    }
  );
}