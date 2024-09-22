{
  lib,
  runCommandLocal,
}:
runCommandLocal "sway-bin" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = fileFilter (f: !f.hasExt "nix") ./.;
  };
} ''
  install -Dm755 -t $out/bin $src/*
''
