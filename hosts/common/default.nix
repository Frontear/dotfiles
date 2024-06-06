{ inputs, outputs, config, lib, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    outputs.nixosModules.default
  ];

  # Sets system stateVersion, do not change.
  system.stateVersion = "24.05";

  # Enables flakes and unfree packages.
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  nixpkgs.config.allowUnfree = true;

  # Tells home-manager to use the system pkgs instance,
  # to install packages via users.extraUsers.<name>.packages,
  # and to set the main user's stateVersion to the system
  # stateVersion.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.frontear = { home.stateVersion = config.system.stateVersion; };
  };

  # Helpful documentation flags
  documentation = {
    dev.enable = true;
    # TODO: necessity of below?
    #man.generateCaches = true;
    nixos.includeAllModules = true;
  };

  # /tmp is where nix builds occur, and they require
  # a LOT of space at times. We will persist the /tmp
  # directory and ensure its cleaned up to alleviate
  # this problem.
  boot.tmp = {
    cleanOnBoot = true;
    useTmpfs = lib.mkForce false;
  };
  impermanence.system.directories = [ "/tmp" ];
}
