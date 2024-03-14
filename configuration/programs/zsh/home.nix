{ ... }: {
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    extraOptions = [
      "--group"
      "--group-directories-first"
      "--header"
      "--octal-permissions"
    ];
    git = true;
    icons = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    historySubstringSearch.enable = true;
    initExtra = ''
      prompt off

      PS1='%B%F{green}[%n@%m %1~]%(#.#.$)%F{white}%b '
      RPS1='%B%(?.%F{green}.%F{red})%?%f%b' # https://unix.stackexchange.com/a/375730
    '';
    syntaxHighlighting.enable = true;
  };
}
