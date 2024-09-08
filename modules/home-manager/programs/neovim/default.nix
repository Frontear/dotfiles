{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.programs.neovim = {
    enable = lib.mkEnableOption "neovim" // { default = true; };
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
    warnings = [
      "WARN: Impermanence not configured! (persist ~/.local/share/lvim)"
    ];

    home.packages = [ config.my.programs.neovim.package ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}