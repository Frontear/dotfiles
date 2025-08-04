{
  lib,
  runCommandNoCCLocal,

  swaylock,
}:
runCommandNoCCLocal "fs-swayidle" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = difference ./. ./default.nix;
  };
} ''
  install -Dm644 {$src,$out}/config

  substituteInPlace $out/config \
    --subst-var-by swaylock ${lib.getExe swaylock}
''
