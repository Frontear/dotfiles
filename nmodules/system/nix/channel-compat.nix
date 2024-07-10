{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.nix.enable {
    nix.channel.enable = true;

    # nix.nixPath
    # nix.registry
  };
}