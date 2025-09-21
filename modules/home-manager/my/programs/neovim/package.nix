{
  lib,
  neovimUtils,
  wrapNeovimUnstable,

  neovim-unwrapped,

  # from module
  extraBins,
  plugins,
}:
wrapNeovimUnstable neovim-unwrapped (neovimUtils.makeNeovimConfig {
  # withPython3 = true;
  # withNodeJs = false;
  # withRuby = true;

  inherit plugins;

  wrapRc = false;
} // {
  wrapperArgs = lib.escapeShellArgs [ "--prefix" "PATH" ":" "${lib.makeBinPath extraBins}" ];
})