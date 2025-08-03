{
  symlinkJoin,
  makeWrapper,

  element-desktop,
}:
symlinkJoin {
  name = "element-desktop";
  paths = [
    element-desktop
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/element-desktop \
      --set-default NIXOS_OZONE_WL 1
  '';
}
