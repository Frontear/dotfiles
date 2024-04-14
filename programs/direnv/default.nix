{ outputs, config, ... }: {
  imports = [
    outputs.nixosModules.main-user
  ];

  # User
  home-manager.users.${config.main-user.name} = { config, ... }: {
    programs.direnv = {
      enable = true;

      config = {
        whitelist = {
          prefix = [ "${config.home.homeDirectory}/Documents/projects" ];
        };
      };

      nix-direnv.enable = true;
    };
  };
}