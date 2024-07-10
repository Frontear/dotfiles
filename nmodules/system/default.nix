inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (import ./nix inputs)
  ];
}