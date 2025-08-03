{
  lib,
  symlinkJoin,
  makeWrapper,

  inxi,

  bluez,
  bluez-tools,
  busybox,
  dig,
  dmidecode,
  lm_sensors,
  smartmontools,
  toybox,
  usbutils,
  virtualgl,
  vulkan-tools,
  wayland-utils,
}:
let
  runtimeInputs = [
    bluez
    bluez-tools
    busybox
    dig
    dmidecode
    lm_sensors
    smartmontools
    toybox
    usbutils
    virtualgl
    vulkan-tools
    wayland-utils
  ];
in symlinkJoin {
  name = "inxi";
  paths = [
    inxi
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/inxi \
      --prefix PATH : ${lib.makeBinPath runtimeInputs}
  '';
}
