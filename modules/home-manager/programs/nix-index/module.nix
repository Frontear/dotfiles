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
      # Disable the `command-not-found` replacement functionality.
      programs.nix-index.enableZshIntegration = false;
    })
  ];
}