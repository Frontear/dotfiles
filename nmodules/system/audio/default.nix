{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.system.audio;
in {
  imports = [
    ./pipewire.nix
  ];

  options.my.system.audio.enable = mkEnableOption "audio";

  config = mkIf cfg.enable {
    services.pipewire.enable = true;
  };
}