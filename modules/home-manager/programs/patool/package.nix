{
  lib,
  symlinkJoin,
  makeWrapper,

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
symlinkJoin {
  name = "patool";
  paths = [ patool ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/patool \
      --prefix PATH : ${lib.makeBinPath [
        archiver
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
        lha
        lrzip
        lz4
        lzip
        lzop
        monkeysAudio
        ncompress
        p7zip
        rar
        rzip
        sharutils
        unar
        xz
        zpaq
        zstd
      ]}
  '';
}
