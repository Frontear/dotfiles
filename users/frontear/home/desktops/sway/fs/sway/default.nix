{
  lib,
  runCommandNoCCLocal,

  screenshot,
}:
runCommandNoCCLocal "fs-sway" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = difference ./. ./default.nix;
  };
} ''
  install -Dm644 -t $out/backgrounds $src/backgrounds/*
  install -Dm644 {$src,$out}/config

  substituteInPlace $out/config \
    --subst-var-by backgrounds $out/backgrounds \
    --subst-var-by screenshot ${lib.getExe screenshot}
''
