{
  lib,
  stdenvNoCC,

  coreutils,
  util-linux,
}:
stdenvNoCC.mkDerivation {
  pname = "persist-helper";
  version = "0.1.1";

  src = ./src;

  env = {
    path = lib.makeBinPath [
      coreutils
      util-linux
    ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 persist-helper.sh $out/bin/persist-helper

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/bin/persist-helper \
      --subst-var path
  '';

  meta = with lib; {
    description = "Helper script to safely configure an ephemeral root setup";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "persist-helper";
  };
}
