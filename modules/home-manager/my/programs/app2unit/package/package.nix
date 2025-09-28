{
  lib,
  stdenvNoCC,

  app2unit,
}:
stdenvNoCC.mkDerivation {
  pname = "app2unit-wrapper";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ./.;
    fileset = unions [
      ./src
    ];
  };

  env = {
    app2unit = lib.getExe app2unit;
  };

  installPhase = ''
    install -Dm755 src/app2unit.sh $out/bin/app2unit

    substituteInPlace $out/bin/app2unit \
      --subst-var app2unit
  '';

  meta = with lib; {
    description = "Launch applications through app2unit with specific fixes";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "app2unit";
  };
}