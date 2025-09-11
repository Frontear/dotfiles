{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.nix-index;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.cache/nix-index"
    ];

    programs = {
      command-not-found.enable = lib.mkForce false;

      nix-index = {
        inherit (cfg)
          enable
          package
          ;
      };
    };
  };
}