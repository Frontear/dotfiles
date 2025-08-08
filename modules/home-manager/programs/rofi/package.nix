{
  lib,
  symlinkJoin,
  makeWrapper,

  rofi,

  extraArgs ? ""
}:
symlinkJoin {
  name = "rofi";
  paths = [
    rofi
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/rofi \
      --add-flags ${lib.escapeShellArg extraArgs}
  '';
}
