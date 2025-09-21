{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.nix;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.cache/nix";
      unique = false;
    }];
  };
}