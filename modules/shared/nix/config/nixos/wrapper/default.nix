{
  lib,
  stdenvNoCC,

  nix,
}:
stdenvNoCC.mkDerivation {
  inherit (nix) name version;

  src = with lib.fileset; toSource {
    root = ./.;
    fileset = unions [
      ./nix.sh
    ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 nix.sh $out/bin/nix

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/bin/nix \
      --subst-var-by nix ${lib.getExe nix}
  '';

  meta = with lib; {
    description = "Very bare-bones wrapper around the Nix CLI";

    license = licenses.free;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "nix";
  };
}