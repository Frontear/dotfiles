{
  lib,
  symlinkJoin,
  makeWrapper,

  atool,

  file,
  gnutar,
  gzip,
  bzip2,
  pbzip2,
  lzip,
  plzip,
  lzop,
  xz,
  zip, unzip,
  rar, unrar,
  lha,
  arj,
  rpm,
  cpio,
  p7zip,
}:
symlinkJoin {
  name = "atool";
  paths = [ atool ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/atool \
      --prefix "PATH" ":" "${lib.makeBinPath [
        file
        gnutar
        gzip
        bzip2
        pbzip2
        lzip
        plzip
        lzop
        xz
        zip unzip
        rar unrar
        lha
        arj
        rpm
        cpio
        p7zip
      ]}"
  '';
}