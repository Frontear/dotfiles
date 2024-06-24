{ ... }: ({ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.terminal;
in {
  config = mkIf cfg.enable {
    home-manager.users.frontear = { ... }: {
      programs.git = {
        enable = true;

        delta = {
          enable = true;

          options = {
            line-numbers = true;
          };
        };

        signing = {
          key = "BCB5CEFDE22282F5";
          signByDefault = true;
        };

        userEmail = "perm-iterate-0b@icloud.com";
        userName = "Ali Rizvi";
      };
    };
  };
})