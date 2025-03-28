{
  lib,
  symlinkJoin,
  makeWrapper,
  gcc13Stdenv,

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
  lha,
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
  stdenv = gcc13Stdenv;

  lha' = lha.override {
    inherit stdenv;
  };

  rzip' = rzip.override {
    inherit stdenv;
  };
in symlinkJoin {
  name = "patool";
  paths = [ patool ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/patool \
      --prefix PATH : ${lib.makeBinPath [
        file

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
        lha'
        lrzip
        lz4
        lzip
        lzop
        monkeysAudio
        ncompress
        rar
        rzip'
        sharutils
        unar
        xz
        zpaq
        zstd
      ]}
  '';
}
