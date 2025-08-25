{
  lib,
  runCommandNoCCLocal,

  sassc,
}:
runCommandNoCCLocal "waybar-style" {
  src = with lib.fileset; toSource {
    root = ./.;
    fileset = ./style.scss;
  };

  nativeBuildInputs = [
    sassc
  ];
} ''
  sassc $src/style.scss $out
''
