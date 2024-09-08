{
  options,
  config,
  lib,
  pkgs,
  ...
}:
lib.mkMerge [
  ({
    # Sets up user
    users.extraUsers.frontear = {
      initialHashedPassword = "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";

      extraGroups = [ "wheel" ] ++
      (lib.optional config.networking.networkmanager.enable "networkmanager");
    };
  })
  # Set the default user in WSL context
  (lib.optionalAttrs (options ? wsl.defaultUser) {
    wsl.defaultUser = "frontear";
  })
  ({
    # Sets shell to ZSH
    users.extraUsers.frontear.shell = pkgs.zsh;
    programs.zsh = {
      enable = true;
      enableBashCompletion = true;
      enableCompletion = true;
      enableGlobalCompInit = true;

      promptInit = "";
    };
  })
]