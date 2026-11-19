{
  lib,
  stdenvNoCC,

  deadnix,
}:
stdenvNoCC.mkDerivation {
  pname = "flake-fmt";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../.;
    fileset = unions [
      ../src
    ];
  };

  env = {
    path = lib.makeBinPath [
      deadnix
    ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 src/flake-fmt.sh $out/bin/flake-fmt

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/bin/flake-fmt \
      --subst-var path
  '';

  meta = with lib; {
    description = "Simple script to be used on a flake's formatter output";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "flake-fmt";
  };
}