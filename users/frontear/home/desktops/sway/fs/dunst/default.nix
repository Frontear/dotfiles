{
  lib,
  runCommandNoCCLocal,
}:
runCommandNoCCLocal "fs-dunst" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = difference ./. ./default.nix;
  };
} ''
  install -Dm644 {$src,$out}/dunstrc
''
