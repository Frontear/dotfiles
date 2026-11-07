{
  lib,
  stdenvNoCC,

  nixVersions,
  lixPackageSets,

  coreutils,
  hyperfine,
}:
let
  nixDrvs =
    nixVersions
    |> lib.attrValues
    |> lib.map lib.tryEval
    |> lib.map (x: x.value)
    |> lib.filter lib.isDerivation
    |> lib.unique;
  lixDrvs =
    lixPackageSets
    |> lib.attrValues
    |> lib.map lib.tryEval
    |> lib.map (x: x.value)
    |> lib.filter (x: lib.isAttrs x && lib.hasAttr "lix" x)
    |> lib.map (x: x.lix)
    |> lib.unique;
in stdenvNoCC.mkDerivation {
  pname = "nix-benchmark";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../.;
    fileset = unions [
      ../src
    ];
  };

  env = {
    nixBins = lib.escapeShellArgs (map lib.getExe (nixDrvs ++ lixDrvs));

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