{
  lib,
  pkgs,
  ...
}:
{
  my.programs.git = {
    enable = true;

    config = import ./config.nix "${lib.getExe pkgs.delta}";
    ignores = [
      ".envrc"
    ];
  };
}