{
  lib,
  stdenv,
  fetchFromGitHub,

  fetchpatch,

  autoconf-archive,
  autoreconfHook,
  pkg-config,

  gettext,
  libnl,
  libtraceevent,
  libtracefs,
  ncurses,
  pciutils,
  zlib,

  xorg,
}:

stdenv.mkDerivation {
  pname = "powertop";
  version = "2.15-unstable-2025-06-27";

  src = fetchFromGitHub {
    owner = "fenrus75";
    repo = "powertop";
    rev = "49045c0c8ca7d3f47b8e289a9436d5ab2f4e93d9";
    hash = "sha256-OrDhavETzXoM6p66owFifKXv5wc48o7wipSypcorPmA=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # Prevents `--auto-tune` from affecting I/O devices like mouse and keyboard.
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/fenrus75/powertop/pull/164.diff";
      hash = "sha256-qAsLMEnyDr04Xvkpzo51ozTnNAI3co2tENMQUv4jrsA=";
    })
  ];

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    gettext
    libnl
    libtraceevent
    libtracefs
    ncurses
    pciutils
    zlib
  ];


  postPatch = ''
    substituteInPlace src/main.cpp --replace-fail "/sbin/modprobe" "modprobe"
    substituteInPlace src/calibrate/calibrate.cpp --replace-fail "/usr/bin/xset" "${lib.getExe xorg.xset}"
    substituteInPlace src/tuning/bluetooth.cpp --replace-fail "/usr/bin/hcitool" "hcitool"
  '';
}