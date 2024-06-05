{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.programs.microsoft-edge;

  user-data-dir = ".config/microsoft-edge";
in {
  options.frontear.programs.microsoft-edge = {
    enable = mkEnableOption "opinionated microsoft-edge module.";
  };

  config = mkIf cfg.enable {
    impermanence.user.directories = [ user-data-dir ];

    users.extraUsers.frontear.packages = with pkgs; [
      (microsoft-edge.override {
        commandLineArgs = "--user-data-dir=${user-data-dir}";
      })
    ];
  };
}