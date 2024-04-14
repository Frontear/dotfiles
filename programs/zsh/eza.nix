{ outputs, config, ... }: {
  imports = [
    outputs.nixosModules.main-user
  ];

  home-manager.users.${config.main-user.name} = { config, ... }: {
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