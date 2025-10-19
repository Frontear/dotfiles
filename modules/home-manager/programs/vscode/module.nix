{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.vscode;
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      "~/.config/Code"
    ];
  };
}