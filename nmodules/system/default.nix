{
  lib,
  ...
}:
{
  imports = lib.importsRecursive ./. (x: x == "default.nix");
}