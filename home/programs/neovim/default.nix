{
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;

    extraConfigLua = ''
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
                                             
    vim.opt.number = true
    vim.cmd("highlight LineNr ctermfg=grey")
    '';
    plugins = {
      lightline.enable = true;
      lsp = {
        enable = true;
        servers = {
          ccls.enable = true;
          nixd.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };
      nvim-cmp = {
        enable = true;

        mapping = {
          "<Down>" = {
            action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end
            '';
          };

          "<Up>" = {
            action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end
            '';
          };

          "<CR>" = {
          action = ''
          function(fallback)
            if cmp.visible() then
              cmp.confirm()
            else
              fallback()
            end
          end
          '';
          };
        };

        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
      treesitter.enable = true;
    };
  };
}
