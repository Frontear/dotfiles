{
  lib,
  stdenvNoCC
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "app";
  version = "0.1.0";

  src = /var/empty;

  meta = with lib; {
  };
})
