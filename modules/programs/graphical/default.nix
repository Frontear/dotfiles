{ nixvim, nix-vscode-extensions, ... }: ({ lib, ... }:
let
  inherit (lib) mkEnableOption;
in {
  imports = lib.forEach (lib.filter (p: p != ./default.nix) (lib.filesystem.listFilesRecursive ./.)) (f: (import f { inherit nixvim nix-vscode-extensions; }));

  options.frontear.programs.graphical = {
    enable = mkEnableOption "opinionated graphical programs.";
  };
})