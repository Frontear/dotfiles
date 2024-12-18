{
  lib,
  stdenvNoCC,

  installShellFiles,
  pandoc,

  coreutils,
}:
stdenvNoCC.mkDerivation {
  pname = "nixos-clean";
  version = "0.1.0";

  src = ./src;

  nativeBuildInputs = [
    installShellFiles
    pandoc
  ];

  buildPhase = ''
    pandoc nixos-clean.1.md -f markdown -t man -s -o nixos-clean.1
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 nixos-clean.sh $out/bin/nixos-clean

    installManPage nixos-clean.1

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/bin/nixos-clean \
      --subst-var-by path ${lib.makeBinPath [ coreutils ]}
  '';

  meta = with lib; {
    description = "Utility script to clean up NixOS/Home-Manager generations from your system";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "nixos-clean";
  };
}
