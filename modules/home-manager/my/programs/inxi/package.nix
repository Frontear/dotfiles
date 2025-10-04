{
  lib,
  symlinkJoin,
  makeWrapper,

  inxi,

  # `inxi --recommnds` system programs
  bluez-tools,
  dig,
  dmidecode,
  file,
  hddtemp,
  iproute2,
  kmod,
  lm_sensors,
  lvm2,
  mdadm,
  pciutils,
  procps,
  smartmontools,
  tree,
  usbutils,

  # `inxi --recommends` display information programs
  mesa-demos,
  vulkan-tools,
  wayland-utils,
  wlr-randr,
}:
let
  runtimeInputs = [
    bluez-tools
    dig
    dmidecode
    file
    hddtemp
    iproute2
    kmod
    lm_sensors
    lvm2
    mdadm
    pciutils
    procps
    smartmontools
    tree
    usbutils

    mesa-demos
    vulkan-tools
    wayland-utils
    wlr-randr
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