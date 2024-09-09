{
  ...
}:
{
  my.programs.zsh = {
    enable = true;

    history = {
      save = 10000;
      size = 10000;
    };

    plugins = {
      autosuggestions = {
        enable = true;
        strategy = [ "history" ];
      };

      syntax-highlighting = {
        enable = true;
        highlighters = [ "main" "brackets" ];
      };
    };

    promptInit = ''
      PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
      RPS1='%B%(?.%F{green}.%F{red})%?%f%b'
    '';
  };
}