{
  lib,
  stdenvNoCC,

  coreutils,
  util-linux,
}:
stdenvNoCC.mkDerivation {
  pname = "persist-helper";
  version = "0.1.1";

  src = with lib.fileset; toSource {
    root = ./.;
    fileset = unions [
      ./persist-helper.sh
    ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 persist-helper.sh $out/bin/persist-helper

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/bin/persist-helper \
      --subst-var-by path ${lib.makeBinPath [ coreutils util-linux ]}
  '';

  meta = with lib; {
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "persist-helper";
  };
}
