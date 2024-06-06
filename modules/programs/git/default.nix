{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.programs.git;
in {
  options.frontear.programs.git = {
    enable = mkEnableOption "opinionated git module.";
  };

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
}