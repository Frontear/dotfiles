{
  lib,
  stdenvNoCC,

  coreutils,
  grim,
  slurp,
  wl-clipboard,
}:
stdenvNoCC.mkDerivation {
  pname = "screenshot";
  version = "0.1.0";

  src = ./src;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src/screenshot.sh $out/bin/screenshot

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/bin/screenshot \
      --subst-var-by path ${lib.makeBinPath [
        coreutils
        grim
        slurp
        wl-clipboard
      ]}
  '';

  meta = with lib; {
    description = "Quick and fast script to capture a screenshot for Sway";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "screenshot";
  };
}
