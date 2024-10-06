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
      vim.opt.cursorline = true

      vim.opt.scrolloff = 5
      vim.opt.textwidth = 80

      vim.opt.wrap = true
      vim.opt.undofile = true

      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true

      vim.opt.number = true
      vim.cmd("highlight LineNr ctermfg=grey")

      require("editorconfig").properties = {
        charset = "utf-8",
        indent_size = "2",
        indent_style = "space",
        max_line_length = 80,
        tab_width = 2,
        trim_trailing_whitespace = true,
      }
    '';

    plugins = [
      {
        plugins = with pkgs.vimPlugins; [
          onedark-nvim
        ];

        config = ''
          local onedark = require("onedark")

          onedark.setup({
            style = "darker"
          })

          onedark.load()
        '';
      }
      {
        bins = with pkgs; [
          basedpyright
          clang-tools
          nixd
        ];

        plugins = with pkgs.vimPlugins; [
          cmp-buffer
          cmp-nvim-lsp
          cmp-async-path
          cmp_luasnip
          luasnip
          nvim-cmp

          nvim-lspconfig
        ];

        config = ''
          local cmp = require("cmp")

          cmp.setup({
            snippet = {
              expand = function(args)
                require("luasnip").lsp_expand(args.body)
              end,
            },

            sources = cmp.config.sources({
              { name = "luasnip" },
              { name = "nvim_lsp" },
              { name = "buffer" },
              { name = "async_path" },
            }),
          })

          local lspconfig = require("lspconfig")
          local capabilities = require("cmp_nvim_lsp").default_capabilities()

          lspconfig.basedpyright.setup({
            capabilities = capabilities,
          })

          lspconfig.clangd.setup({
            capabilities = capabilities,
          })

          lspconfig.nixd.setup({
            capabilities = capabilities,
          })
        '';
      }
      {
        plugins = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
        ];

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
        plugins = with pkgs.vimPlugins; [
          lualine-nvim
        ];

        config = ''
          require("lualine").setup({
            theme = "onedark",
            sections = {
              lualine_c = {
                "filename",
              },
              lualine_x = {
                "filetype",
              },
            }
          })
        '';
      }
    ];
  };
}
