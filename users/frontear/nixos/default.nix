{
  config,
  lib,
  ...
}:
{
  imports = [
    ./per-host.nix
    ./shell.nix
  ];

  config.users.users."frontear" = {
    initialHashedPassword = "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";

    extraGroups = [ "wheel" ] ++
      (lib.optional config.my.services.networkmanager.enable "networkmanager") ++
      (lib.optional config.my.desktops.sway.enable "input");
  };
}