{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zed-editor;
in {
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      package = pkgs.zed-editor.fhs;
    };

    my.persist.directories = [
      "~/.local/share/zed"
      # TODO: needed?
      # "~/.config/zed"
    ];
  };
}