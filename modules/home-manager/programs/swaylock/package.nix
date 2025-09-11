{
  lib,
  symlinkJoin,
  makeWrapper,

  swaylock,

  extraArgs ? "",
}:
symlinkJoin {
  name = lib.getName swaylock;
  paths = [
    swaylock
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/swaylock \
      --add-flags ${lib.escapeShellArg extraArgs}
  '';
}