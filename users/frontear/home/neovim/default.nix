{
  pkgs,
  ...
}:
{
  my.programs.neovim = {
    enable = true;

    extraBins = with pkgs; [
      wl-clipboard
    ];

    init = ''
      vim.opt.wrap = true

      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true

      vim.opt.number = true
      vim.cmd("highlight LineNr ctermfg=grey")
    '';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = onedark-nvim;
        config = ''
          local onedark = require("onedark")

          onedark.setup({
            style = "darker"
          })

          onedark.load()
        '';
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = ''
          require("nvim-treesitter.configs").setup({
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
            },
          })
        '';
      }
      {
        plugin = lualine-nvim;
        config = ''
          require("lualine").setup({
            theme = "onedark",
            sections = {
              lualine_c = {
                "filename",
              }
            }
          })
        '';
      }
    ];
  };
}
