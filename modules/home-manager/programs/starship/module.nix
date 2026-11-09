{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.starship;

  conf = config.home.file."${cfg.configPath}".source;
in {
  config = lib.mkIf cfg.enable {
    home.sessionVariables."STARSHIP_CONFIG" = lib.mkForce conf;

    home.file."${cfg.configPath}".enable = lib.mkForce false;
  };
}