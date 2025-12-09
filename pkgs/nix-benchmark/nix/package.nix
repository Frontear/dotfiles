{
  lib,
  stdenvNoCC,

  nixVersions,
  lixPackageSets,

  coreutils,
  hyperfine,
}:
stdenvNoCC.mkDerivation {
  pname = "nix-benchmark";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../.;
    fileset = unions [
      ../src
    ];
  };

  env = {
    nixBins = lib.escapeShellArgs (map lib.getExe [
      nixVersions.nix_2_28
      nixVersions.nix_2_29
      nixVersions.nix_2_30
      nixVersions.nix_2_31
      nixVersions.nix_2_32
      nixVersions.git
      lixPackageSets.lix_2_93.lix
      lixPackageSets.lix_2_94.lix
      lixPackageSets.git.lix
    ]);

    path = lib.makeBinPath [
      coreutils
      hyperfine
    ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm755 src/nix-benchmark.sh $out/bin/nix-benchmark

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/bin/nix-benchmark \
      --subst-var nixBins \
      --subst-var path
  '';

  meta = with lib; {
    description = "Utility script to benchmark eval times of a derivation";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "nix-benchmark";
  };
}