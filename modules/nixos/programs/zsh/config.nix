{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.zsh;
in {
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;

      enableBashCompletion = true;
      enableCompletion = true;
      enableGlobalCompInit = true;

      promptInit = lib.mkForce "";
    };
  };
}
