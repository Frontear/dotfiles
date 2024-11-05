{
  lib,
  runCommandNoCC,

  makeWrapper,

  cachix,
  gitMinimal,
  gnused,
  jq,
  nh,
}:
runCommandNoCC "introduce-bin" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  install -Dm755 -t $out/bin ${./.}/*

  wrapProgram $out/bin/cachix-push \
    --prefix PATH : ${lib.makeBinPath [ cachix gnused jq ]}

  wrapProgram $out/bin/rebuild \
    --prefix PATH : ${lib.makeBinPath [ gitMinimal nh ]}
''
