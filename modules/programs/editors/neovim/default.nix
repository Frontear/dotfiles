{ inputs, config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frontear.programs.editors.neovim;
in {
  options.frontear.programs.editors.neovim = {
    enable = mkEnableOption "opinionated neovim module.";
  };

  config = mkIf cfg.enable {
    home-manager.users.frontear = { ... }: {
      imports = [
        inputs.nixvim.homeManagerModules.nixvim
      ];

      programs.nixvim = {
        enable = true;

        colorschemes.onedark.enable = true;

        extraConfigLua = ''
          vim.opt.tabstop = 4
          vim.opt.shiftwidth = 4
          vim.opt.expandtab = true
          vim.opt.number = true
          vim.cmd("highlight LineNr ctermfg=grey")
        '';

        plugins = {
          lightline.enable = true;
          treesitter.enable = true;
        };
      };
    };
  };
}