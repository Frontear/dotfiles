{
  lib,
  stdenv,
  fetchFromGitHub,

  meson,
  ninja,
  pkg-config,

  pciutils,

  gettext,
  libnl,
  libtraceevent,
  libtracefs,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "powertop";
  version = "2.16.1-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "fenrus75";
    repo = "powertop";
    rev = "993dc340c43b51655fb43c4cfa64883348b30583";
    hash = "sha256-ifo01yE3EMWBUSap5W9hUHtPQLAiX0qKc03N1hsELts=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gettext
    libnl
    libtraceevent
    libtracefs
    ncurses
  ];

  postPatch = ''
    substituteInPlace src/main.cpp --replace-fail "/sbin/modprobe" "modprobe"
    substituteInPlace src/lib.cpp \
      --replace-fail "/usr/share/hwdata/pci.ids" "${pciutils}/share/pci.ids"
  '';
}