{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.direnv;

  # TODO: why does the NixOS module do this, but home-manager doesn't?
  #
  # see: https://github.com/NixOS/nixpkgs/blob/ea6374f096899fa72e92d848e87fc7842483284d/nixos/modules/programs/direnv.nix#L74
  # see: https://github.com/nix-community/home-manager/blob/3ec1cd9a0703fbd55d865b7fd2b07d08374f0355/modules/programs/direnv.nix#L107
  nix-direnv' = pkgs.nix-direnv.override {
    nix = osConfig.nix.package;
  };
in {
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      inherit (cfg)
        enable
        package
        config
        ;

      nix-direnv = {
        enable = true;
        package = nix-direnv';
      };
    };
  };
}