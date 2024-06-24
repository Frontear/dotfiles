{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in {
  imports = lib.filter (p: p != ./default.nix) (lib.filesystem.listFilesRecursive ./.);

  options.frontear.programs.terminal = {
    enable = mkEnableOption "opinionated terminal programs.";
  };
}