{ ... }: ({ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.terminal;
in {
  config = mkIf cfg.enable {
    users.extraUsers.frontear.packages = with pkgs; [
      (writeShellApplication {
        name = "atool";

        runtimeInputs = with pkgs; [
          file
          gnutar
          gzip
          bzip2
          pbzip2
          lzip
          plzip
          lzop
          xz # lzma
          zip unzip
          rar unrar
          lha
          # unace
          arj
          rpm
          cpio
          # arc nomarch
          p7zip
          #unalz
        ];

        text = ''
          ${lib.getExe pkgs.atool} "$@"
        '';
      })
    ];
  };
})