{
  lib,
  symlinkJoin,
  makeWrapper,

  swayosd,

  brightnessctl,
}:
let
  runtimeInputs = [
    brightnessctl
  ];
in symlinkJoin {
  name = "swayosd";
  paths = [
    swayosd
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/swayosd-server \
      --prefix PATH : ${lib.makeBinPath runtimeInputs}
  '';
}