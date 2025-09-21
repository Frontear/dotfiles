{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.git;
in {
  config = lib.mkMerge [
    {
      programs.git = {
        enable = lib.mkDefault true;
        package = pkgs.gitFull;
      };
    }

    (lib.mkIf cfg.enable {
      programs.git = {
        ignores = [
          ".envrc"
        ];
      };
    })
  ];
}