{
  lib,
  runCommandLocal,

  sassc,
}:
runCommandLocal "fs-swayosd" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = difference ./. ./default.nix;
  };

  nativeBuildInputs = [
    sassc
  ];
} ''
  sassc $src/style.scss style.css

  install -Dm644 {.,$out}/style.css
''