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
      (lib.optional config.networking.networkmanager.enable "networkmanager") ++
      (lib.optional config.my.desktops.sway.enable "input");
    };
  })
  # Set the default user in WSL context
  (lib.optionalAttrs (options ? wsl.defaultUser) {
    wsl.defaultUser = "frontear";
  })
  (lib.mkIf config.my.desktops.sway.enable {
    programs.light.enable = true;
    users.extraUsers.frontear.extraGroups = lib.singleton "video";
  })
  (lib.mkIf config.my.desktops.sway.enable {
    programs.ydotool.enable = true;
    users.extraUsers.frontear.extraGroups =
      lib.singleton config.programs.ydotool.group;
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
