{
  lib,
  ...
}:
{
  imports = lib.pipe ./. [
    lib.filesystem.listFilesRecursive
    (lib.filter (x:
      x != ./default.nix &&
      baseNameOf x == "default.nix"
    ))
  ];
}