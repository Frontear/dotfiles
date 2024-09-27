{
  config,
  lib,
  pkgs,
  ...
}:
{
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

  config = lib.mkIf config.my.programs.neovim.enable {
    my.persist.directories = [ "~/.local/share/lvim" ];

    home.packages = [ config.my.programs.neovim.package ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
