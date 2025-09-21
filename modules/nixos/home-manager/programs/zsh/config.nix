{
  nixosConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.programs.zsh;
  cfgUser = nixosConfig.users.users.${config.home.username};
in {
  config = lib.mkIf cfg.enable {
    programs.zsh.enable = lib.mkForce (cfgUser.shell == pkgs.zsh);
  };
}