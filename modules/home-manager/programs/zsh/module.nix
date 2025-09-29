{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zsh;
in {
  config = lib.mkIf cfg.enable {
    # ZSH tries to atomically replace $HISTFILE, which fails if the file
    # is a bind-mount. As an alternative, persist the entire directory
    # around the file instead.
    my.persist.directories = [{
      path = builtins.dirOf cfg.history.path;
      unique = false;
    }];

    programs.zsh = {
      # Prevent home-manager from trying to include a _second_ ZSH in my  PATH..
      package = pkgs.emptyDirectory;

      # These are set at system-level
      enableCompletion = false;
      completionInit = lib.mkForce "";

      dotDir = lib.mkIf config.xdg.enable
        "${config.xdg.configHome}/zsh";

      history.path = lib.mkIf config.xdg.enable
        "${config.xdg.dataHome}/zsh/zsh_history";

      history.save = 10000;
      history.size = 10000;
    };
  };
}