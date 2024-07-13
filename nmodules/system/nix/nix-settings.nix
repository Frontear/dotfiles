{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.nix.enable {
    # see: https://gist.github.com/Frontear/f88e27b0a5c2841c849a1a21e6b70793
    nix.package = pkgs.lix;

    # https://nix.dev/manual/nix/development/command-ref/conf-file.html
    nix.settings = {
      allow-import-from-derivation = false;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      cores = 0;
      eval-cache = false;
      experimental-features = [
        "auto-allocate-uids"
        "cgroups"
        "flakes"
        "nix-command"
        "no-url-literals"
      ];
      fallback = true;
      flake-registry = "";
      http-connections = 0;
      max-jobs = "auto";
      nix-path = config.nix.nixPath;
      preallocate-contents = true;
      pure-eval = false; # more trouble than its worth
      require-sigs = true;
      sandbox = true;
      sandbox-fallback = false;
      show-trace = true;
      substitute = true;
      sync-before-registering = true;
      trace-verbose = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      use-cgroups = true;
      use-registries = true;
      use-xdg-base-directories = true;
    };
  };
}
