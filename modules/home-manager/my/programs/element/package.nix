{
  lib,
  symlinkJoin,
  makeWrapper,

  element-desktop,

  # NOTE: despite it's name, this will actually force Electron to query the
  # correct `org.freedesktops.secrets` provider through D-BUS. Thus, it's a
  # safe default for any generic provider, _not_ just `gnome-keyring`.
  #
  # see: https://github.com/electron/electron/issues/47436#issuecomment-2995219848
  withArgs ? "--password-store=gnome-libsecret"
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
      --add-flags ${lib.escapeShellArg withArgs}
  '';
}