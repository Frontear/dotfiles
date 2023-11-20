{ pkgs, ... }: let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in {
    home-manager.users."frontear" = {
        home.packages = with pkgs; [
            armcord
            fastfetch
            google-chrome
            gparted
            vscode
        ];

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
            gpg = {
                enable = true;
            };
            zsh = {
                enable = true;
                enableAutosuggestions = true;
                initExtra =
                ''
                autoload -U promptinit && promptinit && prompt redhat && setopt prompt_sp
                '';
                syntaxHighlighting.enable = true;
            };
        };
        services = {
            gpg-agent = {
                enable = true;
                enableSshSupport = true;
                pinentryFlavor = null;
            };
        };

        home.stateVersion = "23.11";
    };
}
