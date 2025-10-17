{
  lib,
  neovimUtils,
  wrapNeovimUnstable,

  neovim-unwrapped,

  # from module
  bins,
  plugins,
  config,
}:
wrapNeovimUnstable neovim-unwrapped (neovimUtils.makeNeovimConfig {
  # withPython3 = true;
  # withNodeJs = false;
  # withRuby = true;

  inherit plugins;

  wrapRc = false;
} // {
  wrapperArgs = lib.escapeShellArgs [
    "--prefix" "PATH" ":" "${lib.makeBinPath bins}"
    "--add-flags" "-u"
    "--add-flags" "${config}"
  ];
})