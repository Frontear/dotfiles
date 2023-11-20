{ pkgs, ... }:
{
    # grab zsh for the user shell
    programs.zsh.enable = true;

    # setup user account
    users.extraUsers."frontear" = {
        extraGroups = [ "wheel" "networkmanager" ];
        # from mkpasswd
        initialHashedPassword = "$y$j9T$IIC3SWPRtOS4FC36BcuEn/$PzdzCQFoR5M6MV4sJh9xqadw8zaTDA3MtYl4mP1hRh2";
        isNormalUser = true;

        shell = pkgs.zsh;
    };
}
