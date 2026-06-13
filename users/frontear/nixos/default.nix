{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    optional
    ;
in {
  imports = [
    ./per-host.nix
    ./shell.nix
  ];

  config = {
    users.users."frontear" = {
      initialHashedPassword = "$y$j9T$gsXwh6NJa62APePZ.7xR00$lLYi86UgQdN1yjOIgqcegfTKsnqkXI4ufQHWdOTiKr6";

      extraGroups = [ "wheel" ] ++
        (optional config.networking.networkmanager.enable "networkmanager") ++
        (optional config.programs.virt-manager.enable "libvirtd");
    };

    # Allow my user to control the OpenRazer daemon.
    hardware.openrazer.users = [
      "frontear"
    ];
  };
}