{
  lib,
  runCommandNoCCLocal,
}:
runCommandNoCCLocal "fs-foot" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = difference ./. ./default.nix;
  };
} ''
  install -Dm644 {$src,$out}/foot.ini
''
