{
  lib,
  stdenvNoCC,

  coreutils,
}:
stdenvNoCC.mkDerivation {
  pname = "nixos-rollback";
  version = "0.1.0";

  src = ./src;

  env = {
    path = lib.makeBinPath [
      coreutils
    ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 nixos-rollback.sh $out/bin/nixos-rollback

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/bin/nixos-rollback \
      --subst-var path
  '';

  meta = with lib; {
    description = "Simple script to rollback the default NixOS generation";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "nixos-rollback";
  };
}
