{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.atool = {
      enable = mkEnableOption "atool";
      finalPackage = mkOption {
        default = with pkgs; writeShellApplication {
          name = "atool";

          runtimeInputs = [
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
            exec ${lib.getExe atool} "$@"
          '';
        };
        type = types.package;
        readOnly = true;
        internal = true;
      };
    };

    config = mkIf config.programs.atool.enable {
      packages = [
        config.programs.atool.finalPackage
      ];
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}