{ config, lib, pkgs, username, ... }: {
    home-manager.users."${username}" = {
        # TODO: dconf.settings

        # TODO: gtk

        # TODO: home
        home.packages = with pkgs; [
            armcord
            fastfetch
        ];
        home.shellAliases = {
            l = "eza -lah --group-directories-first";
        };
        home.stateVersion = "24.05";

        manual.manpages.enable = true;

        # TODO: programs.command-not-found (system has this too)
        programs.chromium.enable = true;
        programs.chromium.package = pkgs.google-chrome;
        programs.chromium.commandLineArgs = [ "--disk-cache-dir=/tmp/chrome-cache" ];
        programs.chromium.dictionaries = with pkgs.hunspellDictsChromium; [ en_US ];
        # TODO: programs.dircolors
        programs.direnv.enable = true;
        programs.direnv.config = {
            whitelist = {
                prefix = [ "${config.users.extraUsers.${username}.home}/Documents/projects" ];
            };
        };
        programs.direnv.nix-direnv.enable = true;
        programs.eza.enable = true;
        programs.eza.enableAliases = true;
        programs.eza.extraOptions = [ "--group-directories-first" "--header" ];
        programs.git.enable = true;
        programs.git.extraConfig.init.defaultBranch = "main";
        programs.git.lfs.enable = true;
        programs.git.signing.key = "BCB5CEFDE22282F5";
        programs.git.signing.signByDefault = true;
        programs.git.userEmail = "perm-iterate-0b@icloud.com";
        programs.git.userName = "Ali Rizvi";
        programs.gpg.enable = true;
        programs.home-manager.enable = true;
        # programs.info.enable = true;
        # TODO: programs.java
        programs.jq.enable = true;
        programs.less.enable = true;
        programs.man.enable = true;
        programs.man.generateCaches = true;
        # TODO: programs.nix-index
        programs.obs-studio.enable = true;
        programs.zsh.enable = true;
        programs.zsh.enableAutosuggestions = true;
        programs.zsh.completionInit = ''
        autoload -U compinit && compinit
        compinit -D $HOME/.local/state/zsh/compdump
        '';
        programs.zsh.dotDir = ".config/zsh";
        programs.zsh.envExtra = ''
        '';
        programs.zsh.history.path = ".local/state/zsh/history";
        programs.zsh.initExtra = ''
        PS1="%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b "
        RPS1="%B%(?.%F{green}.%F{red})%?%f%b" # https://unix.stackexchange.com/a/375730

        bindkey "$(echoti khome)"   beginning-of-line
        bindkey "$(echoti kend)"    end-of-line
        bindkey "$(echoti kich1)"   overwrite-mode
        bindkey "$(echoti kbs)"     backward-delete-char
        bindkey "$(echoti kdch1)"   delete-char
        bindkey "$(echoti kcuu1)"   up-line-or-history
        bindkey "$(echoti kcud1)"   down-line-or-history
        bindkey "$(echoti kcub1)"   backward-char
        bindkey "$(echoti kcuf1)"   forward-char
        bindkey "$(echoti kpp)"     beginning-of-buffer-or-history
        bindkey "$(echoti knp)"     end-of-buffer-or-history
        bindkey "$(echoti kcbt)"    reverse-menu-complete

        if echoti smkx && echoti rmkx; then
            autoload -Uz add-zle-hook-widget
            function zle_application_mode_start { echoti smkx }
            function zle_application_mode_stop { echoti rmkx }
            add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
            add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
        fi
        '';
        programs.zsh.shellAliases = {
            diff = "diff --color=auto";
            grep = "grep --color=auto";
        };
        programs.zsh.syntaxHighlighting.enable = true;

        # TODO: qt

        # services.cliphist.enable = true;
        # TODO: services.clipman/services.clipmenu/...
        # TODO: services.darkman
        services.gpg-agent.enable = true;
        services.gpg-agent.enableExtraSocket = true;
        services.gpg-agent.enableSshSupport = true;
        services.gpg-agent.pinentryFlavor = "curses";
        services.gpg-agent.sshKeys = [ "AF4BF6EE3E68FD7576667BE7D8A7CFA50BC8E9F2" ];
        # TODO: services.random-background
        # TODO: services.redshift
        # TODO: services.udiskie
        # TODO: services.wlsunset

        # TODO: xdg
        xdg.enable = true;
    };

    users.extraUsers."${username}" = {
        extraGroups = [ "networkmanager" "wheel" ];
        ignoreShellProgramCheck = true;
        initialHashedPassword = "$y$j9T$Lu2JSULdxszq90smP9wZW1$BEFwPllaKcrpyA6o3ZCcugYPrWKWWkzdvECi0qtN8JD";
        isNormalUser = true;
        shell = pkgs.zsh;
    };
    users.mutableUsers = false;
    users.users."root".initialHashedPassword = config.users.extraUsers."${username}".initialHashedPassword;
}
