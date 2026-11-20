{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.oo7;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.local/share/keyrings";
      unique = true;
    }];
  };
}