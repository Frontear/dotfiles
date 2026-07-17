{
  lib,
  symlinkJoin,
  makeWrapper,

  patool,

  # To help disambiguate different archives
  file,

  # Various archive formats supported by patool.
  # TODO: arc, unace, unadf, unalz, xdms, shorten, zoo
  _7zz,
  arj,
  bintools,
  bzip2,
  bzip3,
  cabextract,
  cdrkit,
  cpio,
  flac,
  gnutar,
  gzip,
  lcab,
  #lha,
  lrzip,
  lz4,
  lzip,
  lzop,
  monkeysAudio,
  ncompress,
  rar,
  rzip,
  sharutils,
  unar,
  xz,
  zpaq,
  zstd,
}:
let
  # Fix the `file` derivation to resolve a `patool` build failure.
  #
  # TODO: drop when https://github.com/NixOS/nixpkgs/pull/540742 is in unstable
  file' = file.overrideAttrs (prevAttrs: {
    postPatch = (prevAttrs.postPatch or "") + ''
      substituteInPlace src/landlock.c --replace-fail \
        "LANDLOCK_ACCESS_FS_READ_FILE | LANDLOCK_ACCESS_FS_READ_DIR" \
        "LANDLOCK_ACCESS_FS_READ_FILE | LANDLOCK_ACCESS_FS_READ_DIR | LANDLOCK_ACCESS_FS_EXECUTE"
    '';
  });

  # Temporary override to fix the aforementioned issue.
  #
  # TODO: remove with above snippet when PR lands in unstable.
  patool' = patool.override {
    file = file';
  };

  runtimeInputs = [
    file'

    _7zz
    arj
    bintools
    bzip2
    bzip3
    cabextract
    cdrkit
    cpio
    flac
    gnutar
    gzip
    lcab
    #lha
    lrzip
    lz4
    lzip
    lzop
    monkeysAudio
    ncompress
    rar
    rzip
    sharutils
    unar
    xz
    zpaq
    zstd
  ];
in symlinkJoin {
  name = "patool";
  paths = [
    patool'
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/patool \
      --prefix PATH : ${lib.makeBinPath runtimeInputs}
  '';
}