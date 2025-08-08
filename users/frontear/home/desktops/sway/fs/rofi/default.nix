{
  lib,
  runCommandNoCCLocal,
}:
runCommandNoCCLocal "fs-rofi" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = difference ./. ./default.nix;
  };
} ''
  install -Dm644 {$src,$out}/config.rasi
  install -Dm644 {$src,$out}/theme.rasi
''
