{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.nix;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.cache/nix"
    ];
  };
}