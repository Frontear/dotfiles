{ ... }:
{
    # nvim
    programs.neovim = {
        enable = true;
        configure = {
            customRC = ''
            set tabstop=4
            set shiftwidth=4
            set expandtab

            set number
            highlight LineNr ctermfg=grey
            '';
        };
        defaultEditor = true;
    };
}
