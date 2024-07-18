lib:
let
  inherit (builtins) baseNameOf;
  inherit (lib) filter;
  inherit (lib.filesystem) listFilesRecursive;
in {
  /*
    Returns a list of files from the current directory and recursively down
    the directory tree, such that their file name does NOT qualify the predicate
    provided.

    This function is only intended to recursively populate the `imports` in
    the context of the module system. It also excludes the path's default.nix,
    as it would result in a stack overflow if it wasn't (in some cases).

    Example:
      - importsRecursive ./. (x: x != "default.nix") # Returns all files that are not named "default.nix"
      - importsRecursive ./. (x: x == "default.nix") # Returns all files named "default.nix"
  */
  importsRecursive = (path: pred:
    filter (x:
      # We need to exclude the path's default.nix for situations where this is called from the default.nix of said path, else it will infrec
      x != path + /default.nix &&
      pred (baseNameOf x)
    )
    (listFilesRecursive path)
  );
}