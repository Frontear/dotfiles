{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  userOpts = { config, ... }: {
    options.programs.neovim = {
      enable = mkEnableOption "neovim";
      package = mkOption {
        default = pkgs.lunarvim.overrideAttrs {
          nvimAlias = true;
          globalConfig = ''
            vim.opt.tabstop = 4
            vim.opt.shiftwidth = 4
            vim.opt.expandtab = true
            vim.opt.number = true
            vim.cmd("highlight LineNr ctermfg=grey")
          '';
        };

        type = types.package;
        internal = true;
        readOnly = true;
      };
    };

    config = mkIf config.programs.neovim.enable {
      packages = [ config.programs.neovim.package ];
    };
  };
in {
  options.my.users = mkOption {
    type = with types; attrsOf (submodule userOpts);
  };
}