{
  lib,
  runCommandNoCC,

  makeWrapper,

  gitMinimal,
  nh,
}:
runCommandNoCC "introduce-bin" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  install -Dm755 -t $out/bin ${./.}/*

  wrapProgram $out/bin/rebuild \
    --prefix PATH : ${lib.makeBinPath [ gitMinimal nh ]}
''
