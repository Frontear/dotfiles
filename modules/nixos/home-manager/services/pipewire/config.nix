{
  nixosConfig,
  lib,
  ...
}:
let
  cfg = nixosConfig.services.pipewire;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.local/state/wireplumber";
      unique = true;
    }];
  };
}