rec {
  default = { lib, ... }:
  let
    inherit (lib) filter hasSuffix;
    inherit (lib.filesystem) listFilesRecursive;
  in {
    imports = filter (path: path != ./default.nix && hasSuffix "default.nix" path) (listFilesRecursive ./.);
  };

  home-files = default;

  impermanence = default;
}