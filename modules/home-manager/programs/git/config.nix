{
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.git;
in {
  config = lib.mkIf cfg.enable {
    programs.git = {
      inherit (cfg)
        enable
        package
        ;

      extraConfig = cfg.config;

      ignores = [
        ".envrc"
      ];
    };
  };
}