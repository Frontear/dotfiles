{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.graphical;

  user-data-dir = ".config/microsoft-edge";
in {
  config = mkIf cfg.enable {
    impermanence.user.directories = [ user-data-dir ];

    home-manager.users.frontear = { pkgs, ... }: {
      home.packages = with pkgs; [
        (microsoft-edge.override {
          commandLineArgs = "--user-data-dir=${user-data-dir}";
        })
      ];
    };
  };
}