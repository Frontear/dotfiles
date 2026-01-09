{
  lib,
  pkgs,
  ...
}:
{
  my.programs.neovim = {
    enable = true;

    extraBins = with pkgs; [
      wl-clipboard
    ];

    extraConfig = ''
      vim.g.mapleader = ' '
      vim.g.localmapleader = ' '

      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true

      vim.opt.cursorline = true
      vim.opt.number = true
      vim.cmd("highlight LineNr ctermfg=grey")

      vim.opt.scrolloff = 5
      vim.opt.textwidth = 80
      vim.opt.wrap = true

      vim.opt.undofile = true

      vim.opt.splitright = true
      vim.opt.splitbelow = true

      vim.opt.guicursor = ""

      vim.keymap.set('n', "<C-Left>", "<cmd>wincmd h<CR>")
      vim.keymap.set('n', "<C-Right>", "<cmd>wincmd l<CR>")
      vim.keymap.set('n', "<C-Up>", "<cmd>wincmd k<CR>")
      vim.keymap.set('n', "<C-Down>", "<cmd>wincmd j<CR>")
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
          jdt-language-server
          nixd
          rust-analyzer
          zls
        ];

        plugins = with pkgs.vimPlugins; [
          cmp-buffer
          cmp-nvim-lsp
          cmp-async-path
          cmp_luasnip
          luasnip
          nvim-cmp

          lsp-format-nvim

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

          --local lsp_format = require("lsp-format")

          --lsp_format.setup {}

          local capabilities = require("cmp_nvim_lsp").default_capabilities()
          --local on_attach = lsp_format.on_attach

          ${lib.concatStringsSep "\n" (map (lsp: ''
            vim.lsp.config["${lsp}"] = {
              capabilities = capabilities,
              --on_attach = on_attach
            }

            vim.lsp.enable("${lsp}")
          '') [
            "basedpyright"
            "clangd"
            "jdtls"
            "nixd"
            "rust_analyzer"
            "zls"
          ])}
        '';
      }
      {
        plugins = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
        ];

        config = ''
          require("nvim-treesitter").setup({
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