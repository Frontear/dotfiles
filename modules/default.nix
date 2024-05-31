rec {
  default = { lib, ... }:
  let
    inherit (lib) concatLists forEach;
    inherit (lib.filesystem) listFilesRecursive;
  in {
    imports = concatLists (forEach [
      ./system
    ] listFilesRecursive);
  };

  home-files = default;

  impermanence = default;
}