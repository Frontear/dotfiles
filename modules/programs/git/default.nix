{ config, lib, pkgs, ... }:
let
  inherit (lib) getExe mkEnableOption mkIf;

  cfg = config.frontear.programs.git;
in {
  options.frontear.programs.git = {
    enable = mkEnableOption "opinionated git module.";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      #config = mkMerge [
      #  {
      #    init.defaultBranch = "main";
      #  }
      #  {
      #    core.pager = "${getExe pkgs.delta}";
      #    delta = {
      #      line-numbers = true;
      #    };
      #    interactive.diffFilter = "${getExe pkgs.delta} --color-only";
      #  }
      #  {
      #    commit.gpgSign = true;
      #    tag.gpgSign = true;
      #  }
      #  {
      #    user.email = "perm-iterate-0b@icloud.com";
      #    user.name = "Ali Rizvi";
      #    user.signingKey = "BCB5CEFDE22282F5";
      #  }
      #];
    };

    home.file.".config/git/config".text = ''
      [init]
          defaultBranch = "main"

      [core]
          pager = "${getExe pkgs.delta}"
      [delta]
          line-numbers = true
      [interactive]
          diffFilter = "${getExe pkgs.delta} --color-only"

      [commit]
          gpgSign = true
      [tag]
          gpgSign = true

      [user]
          email = "perm-iterate-0b@icloud.com"
          name = "Ali Rizvi"
          signingKey = "BCB5CEFDE22282F5"
    '';
  };
}