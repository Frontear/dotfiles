{
  lunarvim,

  # TODO: can't assume wayland (i mean we _CAN_, but i dont wanna)
  wl-clipboard
}:
(lunarvim.override {
  nvimAlias = true;
  # TODO: move to user-specific
  globalConfig = ''
    vim.opt.wrap = true

    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true

    vim.opt.number = true
    vim.cmd("highlight LineNr ctermfg=grey")
  '';
}).overrideAttrs (prevAttrs: {
  runtimeDeps = (prevAttrs.runtimeDeps or []) ++ [ wl-clipboard ];
})