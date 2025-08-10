{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.zsh;
in {
  options.my.programs.zsh = {
    enable = lib.mkEnableOption "zsh" // {
      default = osConfig.my.programs.zsh.enable;
    };

    dotDir = lib.mkOption {
      default = "${config.xdg.configHome}/zsh";
      description = ''
        Sets ZDOTDIR, the directory where ZSH configuration files are expected.
      '';

      type = with lib.types; str;
    };

    history = {
      file = lib.mkOption {
        default = "${config.xdg.dataHome}/zsh/zsh_history";
        description = ''
          Sets HISTFILE, the location of the history file.
        '';

        type = with lib.types; str;
      };

      save = lib.mkOption {
        default = 1000;
        description = ''
          Sets SAVEHIST, the maximum number of lines saved in the history file.
        '';

        type = with lib.types; numbers.nonnegative;
      };

      size = lib.mkOption {
        default = 1000;
        description = ''
          Sets HISTSIZE, the maximum number of lines saved in an active session.
        '';

        type = with lib.types; numbers.nonnegative;
      };
    };

    plugins = {
      autosuggestions = {
        enable = lib.mkDefaultEnableOption "zsh.plugins.autosuggestions";

        strategy = lib.mkOption {
          default = [];
          description = ''
            Sets `ZSH_AUTOSUGGEST_STRATEGY` to specify the suggestions generation scheme.
          '';

          type = with lib.types; listOf str;
        };
      };

      syntax-highlighting = {
        enable = lib.mkDefaultEnableOption "zsh.plugins.syntax-highlighting";

        highlighters = lib.mkOption {
          default = [];
          description = ''
            Sets `ZSH_HIGHLIGHT_HIGHLIGHTERS` to specify highlighting scheme.
          '';
        };
      };
    };

    promptInit = lib.mkOption {
      default = "";
      description = ''
        Prompt initialization snippet. Can be either `prompt` or `PS1=...`
      '';

      type = with lib.types; lines;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = osConfig.my.programs.zsh.enable;
      message = "Please enable my.programs.zsh to your NixOS configuration.";
    }];

    # Persisting the file itself is not possible due to the way
    # ZSH attempts to merge history files together -- by trying
    # to copy $HISTFILE.new onto $HISTFILE.
    #
    # This doesn't work well on a bind mount, so as a avoidance
    # we simply persist the entire directory the history file
    # is part of. This isn't ideal if the user tries to place
    # the file in an extremely open path (like ~/.history), but
    # there isn't any better handling here.
    my.persist.directories = [
      (builtins.dirOf cfg.history.file)
    ];

    programs.zsh = lib.mkMerge [
      ({
        enable = true;
        package = pkgs.emptyDirectory; # ensure HM doesn't install zsh in user-space
      })
      ({
        # These are intended to be set at system level
        enableCompletion = false;
        completionInit = "";
      })
      ({
        # Setup prompt
        initContent = cfg.promptInit;
      })
      ({
        inherit (cfg) dotDir;
      })
      ({
        # Set history attributes
        history.path = cfg.history.file;
        history.save = cfg.history.save;
        history.size = cfg.history.size;
      })
      ({
        # Set up some plugins
        autosuggestion.enable = cfg.plugins.autosuggestions.enable;
        autosuggestion.strategy = cfg.plugins.autosuggestions.strategy;

        syntaxHighlighting.enable = true;
        syntaxHighlighting.highlighters = cfg.plugins.syntax-highlighting.highlighters;
      })
    ];
  };
}
