{
  osConfig,
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.pipewire;
in {
  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = osConfig.services.pipewire.enable;
      message = "Please enable my.services.pipewire in your NixOS configuration";
    }];


    my.persist.directories = [{
      path = "~/.local/state/wireplumber";
      unique = true;
    }];
  };
}