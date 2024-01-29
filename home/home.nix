{
  config,
  pkgs,
  ...
}: {
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
  programs.nixvim = {
    enable = true;

    extraConfigLua = ''
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
                                             
    vim.opt.number = true
    vim.cmd("highlight LineNr ctermfg=grey")
    '';
    plugins = {
      lightline.enable = true;
      lsp = {
        enable = true;
        servers = {
          ccls.enable = true;
          nixd.enable = true;
          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };
      nvim-cmp = {
        enable = true;

        mapping = {
          "<Down>" = {
            action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end
            '';
          };

          "<Up>" = {
            action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end
            '';
          };

          "<CR>" = {
          action = ''
          function(fallback)
            if cmp.visible() then
              cmp.confirm()
            else
              fallback()
            end
          end
          '';
          };
        };

        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
      treesitter.enable = true;
    };
  };
  #programs.neovim = {
  #  enable = true;
  #  defaultEditor = true;
  #  extraLuaConfig = ''
  #  vim.opt.tabstop = 4
  #  vim.opt.shiftwidth = 4
  #  vim.opt.expandtab = true

  #  vim.opt.number = true
  #  vim.cmd("highlight LineNr ctermfg=grey")
  #  '';
  #  plugins = with pkgs.vimPlugins; [
  #    nvim-treesitter.withAllGrammars
  #  ];
  #};

  # python

  # ranger

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true; # TODO: environment.pathsToLink = [ "/share/zsh" ];
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
      ls = "eza --git --git-ignore";
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
