{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.direnv;
in {
  config = lib.mkMerge [
    { programs.direnv.enable = lib.mkDefault true; }

    (lib.mkIf cfg.enable {
      programs.direnv = {
        nix-direnv = {
          enable = true;
        };
      };
    })
  ];
}