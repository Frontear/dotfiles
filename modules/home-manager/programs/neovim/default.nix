{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.neovim;
in {
  options.my.programs.neovim = {
    enable = lib.mkDefaultEnableOption "neovim";
    package = lib.mkOption {
      default = pkgs.callPackage ./package.nix {};
      defaultText = "<wrapped-drv>";
      description = ''
        The neovim package to use.
      '';

      type = with lib.types; package;
    };
  };

  config = lib.mkIf cfg.enable {
    my.persist.directories = [ "~/.local/share/lvim" ];

    home.packages = [ cfg.package ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
