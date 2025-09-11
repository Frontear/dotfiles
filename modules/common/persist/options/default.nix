{
  lib,
  ...
}:
{
  imports = [
    ./paths.nix
    ./toplevel.nix
  ];

  options = {
    my.persist = {
      enable = lib.mkEnableOption "persist";

      volume = lib.mkOption {
        default = "/nix/persist";

        type = with lib.types; path;
      };
    };
  };
}