{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.nix-index;
in {
  config = lib.mkMerge [
    { programs.nix-index.enable = lib.mkDefault true; }

    (lib.mkIf cfg.enable {
      my.persist.directories = [{
        path = "~/.cache/nix-index";
        unique = false;
      }];

      programs.command-not-found = {
        enable = lib.mkForce false;
      };
    })
  ];
}