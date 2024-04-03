{ ... }: {
  home-manager.users.frontear = { config, ... }: {
    programs.eza = {
      enable = true;

      extraOptions = [
        "--group"
        "--group-directories-first"
        "--header"
        "--octal-permissions"
      ];

      git = true;
      icons = true;
    };
  };
}