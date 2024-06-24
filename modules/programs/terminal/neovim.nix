{ nixvim, ... }: ({ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.frontear.programs.terminal;
in {
  config = mkIf cfg.enable {
    home-manager.users.frontear = { ... }: {
      imports = [
        nixvim.homeManagerModules.nixvim
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
})