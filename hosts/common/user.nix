{ pkgs, username, ... }: let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
    imports = [
        "${home-manager}/nixos"
    ];

    users.mutableUsers = false; # TODO: move to laptop

    programs.zsh.enable = true;
    users.extraUsers."${username}" = {
        extraGroups = [ "wheel" "networkmanager" ];
        initialHashedPassword = "$y$j9T$aoCkwuoV8kY7LgGIwvAwp.$JKK6dzP8IoyLSiOHxtBVpX0mqyI3TOQKJSHIBJx8gc2";
        isNormalUser = true;
        shell = pkgs.zsh;
    };

    home-manager.users."${username}" = {
        home.packages = with pkgs; [
            armcord
            fastfetch
            google-chrome
            gparted
            vscode
        ];

        # TODO: split into modules?
        programs = {
            git = {
                enable = true;
                extraConfig = {
                    init.defaultBranch = "main";
                };
                signing = {
                    key = "BCB5CEFDE22282F5";
                    signByDefault = true;
                };
                userEmail = "perm-iterate-0b@icloud.com";
                userName = "Ali Rizvi";
            };
            gpg.enable = true;
            zsh = {
                enable = true;
                enableAutosuggestions = true;
                initExtra = ''
                autoload -U promptinit && promptinit && prompt redhat && setopt prompt_sp
                '';
                syntaxHighlighting.enable = true;
            };
        };
        services = {
            gpg-agent = {
                enable = true;
                enableSshSupport = true;
                pinentryFlavor = "curses";
            };
        };

        home.stateVersion = "23.11";
    };
}
