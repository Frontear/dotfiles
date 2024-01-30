{
  config,
  inputs,
  pkgs,
  ...
}: {
  main-user = {
    name = "frontear";
    extraConfig = {
      initialHashedPassword = "$y$j9T$UdbhMx5bVd6gnI86Gjh3L.$TAdn8keK0ljg9fOVzApsEimx9wgZ9V116yLAsU2GgE3";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users."${config.main-user.name}" = import ../../../home;
  };
}
