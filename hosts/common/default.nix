{ inputs, outputs, config, lib, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    outputs.nixosModules.impermanence
  ];

  # Sets system stateVersion, do not change.
  system.stateVersion = "24.05";

  # Enables the nix3 commands as well as flakes,
  # setup compatibility between nix-legacy and nix3
  # commands/interfaces, and finally enables non-free
  # packages.
  #
  # Most of this snippet was stolen from Misterio77
  # See: https://github.com/Misterio77/nix-starter-configs
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; }))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;
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
