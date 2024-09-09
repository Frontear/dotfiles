{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.extraUsers = {
    # TODO: all options
    frontear = {
      name = "frontear";
      home = "/home/frontear";
      # TODO: REMOVE WHEN MY.USERS IS GONE
      initialHashedPassword = lib.mkForce "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";

      extraGroups = (
        [ "wheel" ] ++
        (lib.optional config.networking.networkmanager.enable "networkmanager")
      );

      # TODO: MOVE THIS ANYWHERE ELSE
      shell = lib.mkForce pkgs.zsh;

      isNormalUser = true;
    };
  };

  programs.zsh = {
    enable = true;

    enableBashCompletion = true;
    enableCompletion = true;
    enableGlobalCompInit = true;

    promptInit = "";
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;

    users.frontear = ./frontear;
  };
}