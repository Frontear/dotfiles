{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "update-dotfiles";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../.;
    fileset = unions [
      ../src
    ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 src/update-dotfiles.sh $out/bin/update-dotfiles

    runHook postInstall
  '';

  meta = with lib; {
    description = "Helper script to streamline periodic flake updates";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "update-dotfiles";
  };
}