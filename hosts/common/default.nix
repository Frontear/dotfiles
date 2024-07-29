{
  lib,
  ...
}:
let
  inherit (lib) mkForce;
in {
  # Sets system stateVersion, do not change.
  system.stateVersion = "24.05";

  # Use nh (nix helper)
  programs.nh.enable = true;

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
    useTmpfs = mkForce false;
  };
  my.system.persist.directories = [ { path = "/tmp"; mode = "777"; } ];
}
