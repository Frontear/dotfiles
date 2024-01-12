{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./programs
    ./scripts
  ];

  home.packages = with pkgs; [
    fastfetch
  ];

  programs.ags = {
    enable = true;
  };

  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        delta = {
          line-numbers = true;
          side-by-side = true;
        };
      };
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    signing = {
      key = "BCB5CEFDE22282F5";
      signByDefault = true;
    };
    userEmail = "perm-iterate-0b@icloud.com";
    userName = "Ali Rizvi";
  };

  # hyprland

  programs.kitty = {
    enable = true;

    # TODO: font stuff
  };

  # npm

  # TODO: migrate to nixvim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = ''
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true

    vim.opt.number = true
    vim.cmd("highlight LineNr ctermfg=grey")
    '';
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
    ];
  };

  # python

  # ranger

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true; # TODO: environment.pathsToLink = [ "/share/zsh" ];
    completionInit = ''
    autoload -U compinit && compinit -d ${config.xdg.stateHome}/zsh/compdump
    '';
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    envExtra = ''
    export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"
    '';
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
    };

    initExtra = ''
    if [[ -n $SSH_CONNECTION ]]; then
      export EDITOR="vim"
    else
      export EDITOR="nvim"
    fi

    PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
    RPS1='%B%(?.%F{green}.%F{red})%?%f%b' # https://unix.stackexchange.com/a/375730
    
    # https://wiki.archlinux.org/title/Zsh#Key_bindings
    
    bindkey -- "$(echoti khome)"   beginning-of-line
    bindkey -- "$(echoti kend)"    end-of-line
    bindkey -- "$(echoti kich1)"   overwrite-mode
    bindkey -- "$(echoti kbs)"     backward-delete-char
    bindkey -- "$(echoti kdch1)"   delete-char
    bindkey -- "$(echoti kcuu1)"   up-line-or-history
    bindkey -- "$(echoti kcud1)"   down-line-or-history
    bindkey -- "$(echoti kcub1)"   backward-char
    bindkey -- "$(echoti kcuf1)"   forward-char
    bindkey -- "$(echoti kpp)"     beginning-of-buffer-or-history
    bindkey -- "$(echoti knp)"     end-of-buffer-or-history
    bindkey -- "$(echoti kcbt)"    reverse-menu-complete
    
    if echoti smkx > /dev/null 2>&1 && echoti rmkx > /dev/null 2>&1; then
        autoload -Uz add-zle-hook-widget
        function zle_application_mode_start { echoti smkx }
        function zle_application_mode_stop { echoti rmkx }
        add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
        add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
    fi
    '';

    initExtraBeforeCompInit = ''
    # https://wiki.archlinux.org/title/Color_output_in_console#Applications
    
    export LESS="-R --use-color -Dd+r\$Du+b$"
    export MANPAGER="less -R --use-color -Dd+r -Du+b"
    export MANROFFOPT="-P -c"
     
    setopt alwaystoend autolist appendhistory
    '';

    sessionVariables = {
      # https://wiki.archlinux.org/title/XDG_Base_Directory#Support
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      FFMPEG_DATADIR = "${config.xdg.configHome}/ffmpeg";
      GOPATH = "${config.xdg.dataHome}/go";
      GOMODCACHE = "${config.xdg.cacheHome}/go/mod";
      GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
      GTK_RC_FILES = "${config.xdg.configHome}/gtk-1.0/gtkrc";
      GTK2_RC_FILES = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.xdg.configHome}/java";
      NODE_REPL_HISTORY = "${config.xdg.dataHome}/node_repl_history";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
      NUGET_PACKAGES = "${config.xdg.cacheHome}/NuGetPackages";
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      WGETRC = "${config.xdg.configHome}/wgetrc";
      PYTHONSTARTUP = "${config.xdg.configHome}/python/pythonrc";
      PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python";
      PYTHONUSERBASE = "${config.xdg.dataHome}/python";
      # TODO: sbcl support
      
      # ranger --copy-config=rc
      RANGER_LOAD_DEFAULT_RC = "FALSE";
    };

    shellAliases = {
      diff = "diff --color=auto";
      grep = "grep --color=auto";
      ls = "eza";
      l = "ls -lah --group-directories-first";
    };

    syntaxHighlighting = {
      enable = true;
    };
  };

  # .local/bin

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "curses";
    sshKeys = [
      "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2"
    ];
  };
}
