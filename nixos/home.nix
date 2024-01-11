{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fastfetch
  ];

  # ags

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

  # psd (do i need this?)

  # python

  # ranger

  # systemd (i definitely dont need this)

  # yay (lol)

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true; # TODO: environment.pathsToLink = [ "/share/zsh" ];
    completionInit = ''
    autoload -U compinit && compinit -d $XDG_STATE_HOME/zsh/compdump
    '';
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    envExtra = ''
    export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"
    '';
    history = {
      path = ".local/share/zsh/history";
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
    
    if echoti smkx && echoti rmkx; then
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

    profileExtra = ''
    # Security focused umask
    # umask 077
    
    # https://wiki.archlinux.org/title/GnuPG#Home_directory
    
    if [ ! -d "$GNUPGHOME" ]; then
        mkdir -p $GNUPGHOME
    fi
    
    find $GNUPGHOME -type d -exec chmod 0700 {} \;
    find $GNUPGHOME -type f -exec chmod 0600 {} \;
    '';

    sessionVariables =
    let
      # https://wiki.archlinux.org/title/XDG_Base_Directory#User_directories
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    in {
      inherit XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME;

      # https://wiki.archlinux.org/title/XDG_Base_Directory#Support
      CARGO_HOME = "${XDG_DATA_HOME}/cargo";
      # export DISCORD_USER_DATA_DIR="${XDG_DATA_HOME}/discord" # officially undocumented, but used
      FFMPEG_DATADIR = "${XDG_CONFIG_HOME}/ffmpeg";
      GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
      GOPATH = "${XDG_DATA_HOME}/go";
      GOMODCACHE = "${XDG_CACHE_HOME}/go/mod";
      GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";
      GTK_RC_FILES = "${XDG_CONFIG_HOME}/gtk-1.0/gtkrc";
      GTK2_RC_FILES = "${XDG_CONFIG_HOME}/gtk-2.0/gtkrc";
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java";
      NODE_REPL_HISTORY = "${XDG_DATA_HOME}/node_repl_history";
      NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/npmrc";
      NUGET_PACKAGES = "${XDG_CACHE_HOME}/NuGetPackages";
      PASSWORD_STORE_DIR = "${XDG_DATA_HOME}/pass";
      RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
      # export VSCODE_PORTABLE="$XDG_DATA_HOME/vscode" # undocumented and unreliable
      WGETRC = "${XDG_CONFIG_HOME}/wgetrc";
      PYTHONSTARTUP = "${XDG_CONFIG_HOME}/python/pythonrc";
      PYTHONPYCACHEPREFIX = "${XDG_CACHE_HOME}/python";
      PYTHONUSERBASE = "${XDG_DATA_HOME}/python";
      # TODO: sbcl support
      
      # ranger --copy-config=rc
      RANGER_LOAD_DEFAULT_RC="FALSE";
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
