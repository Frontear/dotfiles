{
  lib,

  stdenv,
  mkShellNoCC,
  makeWrapper,

  nh,
  cachix,
  gnused,
  jq,

  nil,
}:
let
  fs = lib.fileset;

  scripts = stdenv.mkDerivation {
    pname = "scripts";
    version = "0.1.0";

    src = fs.toSource {
      root = ./.;
      fileset = fs.unions [
        ./cachix-push
        ./gc
        ./rebuild
      ];
    };

    nativeBuildInputs = [
      makeWrapper
    ];

    buildPhase = ''
      runHook preBuild

      patchShebangs .

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      install -Dm755 ./rebuild $out/bin/rebuild
      install -Dm755 ./gc $out/bin/gc
      install -Dm755 ./cachix-push $out/bin/cachix-push

      wrapProgram $out/bin/rebuild --prefix PATH : ${lib.makeBinPath [ nh ]}
      wrapProgram $out/bin/gc --prefix PATH : ${lib.makeBinPath [ nh ]}
      wrapProgram $out/bin/cachix-push --prefix PATH : ${lib.makeBinPath [ cachix gnused jq ]}

      runHook postInstall
    '';
  };
in mkShellNoCC {
  packages = [
    nil
    scripts
  ];
}
