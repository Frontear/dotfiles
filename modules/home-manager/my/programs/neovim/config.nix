{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.neovim;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [{
      path = "~/.local/state/nvim";
      unique = false;
    }];


    home.packages = [
      cfg.package
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}