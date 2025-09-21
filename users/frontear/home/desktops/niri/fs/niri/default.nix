{
  lib,
  runCommandNoCCLocal,
}:
runCommandNoCCLocal "fs-niri" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = difference ./. ./default.nix;
  };
} ''
  install -Dm644 -t $out/backgrounds $src/backgrounds/*
  install -Dm644 {$src,$out}/config.kdl

  substituteInPlace $out/config.kdl \
    --subst-var-by backgrounds $out/backgrounds
''