{
  lib,
  stdenvNoCC
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "app";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../../app;
    fileset = unions [
    ];
  };

  meta = with lib; {
    description = "App";
    homepage = "https://github.com/Frontear/<app>";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "app";
  };
})