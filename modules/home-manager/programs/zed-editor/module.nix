{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zed-editor;

  zed-editor = pkgs.callPackage ./package.nix {};
in {
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      package = zed-editor;
    };

    my.persist.directories = [
      "~/.local/share/zed"
      # TODO: needed?
      # "~/.config/zed"
    ];
  };
}