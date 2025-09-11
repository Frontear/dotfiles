{
  lib,
  stdenvNoCC
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "app";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../..;
    fileset = unions [
    ];
  };

  meta = with lib; {
  };
})