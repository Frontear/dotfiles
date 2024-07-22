{ nix-vscode-extensions, ... }: ({ lib, ... }:
let
  inherit (lib) mkEnableOption;
in {
  imports = lib.forEach (lib.filter (p: p != ./default.nix) (lib.filesystem.listFilesRecursive ./.)) (f: (import f { inherit nix-vscode-extensions; }));

  options.frontear.programs.terminal = {
    enable = mkEnableOption "opinionated terminal programs.";
  };
})