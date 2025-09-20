{
  lib,
  buildFHSEnv,

  zed-editor,
}:
buildFHSEnv {
  # NOTE: needs this name so that home-manager can correctly `wrapProgram` it.
  #
  # see: https://github.com/nix-community/home-manager/blob/55b1f5b7b191572257545413b98e37abab2fdb00/modules/programs/zed-editor.nix#L166-L178
  name = "zeditor";

  targetPkgs = pkgs: with pkgs; [
    #glibc
  ];

  runScript = "${lib.getExe zed-editor}";
}