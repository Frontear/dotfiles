{
  lib,
  symlinkJoin,
  makeWrapper,
  gcc13Stdenv,

  patool,

  # TODO: unace, unadf, unalz, xdms, shorten, zoo
  archiver,
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
  p7zip,
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

  patool' = (builtins.getFlake "github:NixOS/nixpkgs/7fa1a3c6b3d22f5e53bb765518a749847a25bb65").legacyPackages.${stdenv.system}.patool;

  arj' = arj.override {
    inherit stdenv;
  };

  lha' = lha.override {
    inherit stdenv;
  };

  rzip' = rzip.override {
    inherit stdenv;
  };
in symlinkJoin {
  name = "patool";
  paths = [ patool' ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/patool \
      --prefix PATH : ${lib.makeBinPath [
        archiver
        arj'
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
        p7zip
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
