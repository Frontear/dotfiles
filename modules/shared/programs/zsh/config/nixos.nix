{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.zsh;
in {
  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enableBashCompletion = true;
      enableCompletion = true;
      enableGlobalCompInit = true;

      # Let this be set through home-manager
      promptInit = lib.mkForce "";
    };
  };
}