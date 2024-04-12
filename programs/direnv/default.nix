{ ... }: {
  # User
  home-manager.users.frontear = { config, ... }: {
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