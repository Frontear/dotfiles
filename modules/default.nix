{ nix-vscode-extensions, ... }: ({ lib, ... }: {
  imports = lib.forEach (lib.filter (path: path != ./default.nix && lib.hasSuffix "default.nix" path) (lib.filesystem.listFilesRecursive ./.)) (f: (import f { inherit nix-vscode-extensions; }));
})