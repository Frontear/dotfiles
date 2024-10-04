{
  lib,

  runCommandLocal,
  makeWrapper,

  gitMinimal, nh, cachix, gnused, jq,

  mkShellNoCC,
  nixd
}:
mkShellNoCC {
  packages = [
    nixd
    (runCommandLocal "install-bin" {
      nativeBuildInputs = [ makeWrapper ];
    } ''
      install -Dm755 -t $out/bin ${./bin}/*

      patchShebangs $out

      wrapProgram $out/bin/cachix-push --prefix "PATH" ':' "${lib.makeBinPath [ cachix gnused jq ]}"
      wrapProgram $out/bin/rebuild --prefix "PATH" ':' "${lib.makeBinPath [ gitMinimal nh ]}"
    '')
  ];
}
