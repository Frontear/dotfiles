{ home-manager, ... }: ({ config, lib, pkgs, ... }: {
  imports = [
    home-manager.nixosModules.home-manager
  ];

  # Sets system stateVersion, do not change.
  system.stateVersion = "24.05";

  # Uses the most bleeding-edge nix cli.
  # Also enables flakes and unfree packages.
  nix.package = lib.mkDefault pkgs.nixVersions.git;
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  nixpkgs.config.allowUnfree = true;

  # Use nh (nix helper)
  programs.nh.enable = true;

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
})
