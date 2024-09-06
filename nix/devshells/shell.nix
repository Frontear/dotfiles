let
  flake-lock = builtins.fromJSON (builtins.readFile ../../flake.lock);
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/${flake-lock.nodes.nixpkgs.locked.rev}";
    sha256 = "${flake-lock.nodes.nixpkgs.locked.narHash}";
  };
in { pkgs ? import nixpkgs {} }: pkgs.callPackage
({
  lib,

  stdenv,
  mkShellNoCC,
  makeWrapper,

  gitMinimal,
  nh,
  cachix,
  gnused,
  jq,

  nil,
}:
let
  scripts = stdenv.mkDerivation {
    pname = "scripts";
    version = "0.1.2";

    src = ./bin;

    nativeBuildInputs = [
      makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      install -Dm755 ./rebuild $out/bin/rebuild
      install -Dm755 ./gc $out/bin/gc
      install -Dm755 ./cachix-push $out/bin/cachix-push

      wrapProgram $out/bin/rebuild --prefix PATH : ${lib.makeBinPath [ gitMinimal nh ]}
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
}) { }