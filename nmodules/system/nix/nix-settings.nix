{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.my.system.nix;
in {
  config = mkIf cfg.enable {
    # Force as an overlay to propagate to everything correctly.
    # see: https://gist.github.com/Frontear/f88e27b0a5c2841c849a1a21e6b70793
    nixpkgs.overlays = [
      (final: prev: {
        nix = prev.lix;
      })
    ];

    # https://nix.dev/manual/nix/development/command-ref/conf-file.html
    nix.settings = {
      allow-import-from-derivation = false;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      cores = 0;
      eval-cache = false;
      extra-substituters = [
        "https://frontear.cachix.org"
      ];
      extra-trusted-public-keys = [
        "frontear.cachix.org-1:rrVt1C9dFaJf9QpG1Vu6sHqEUy0Q8ezLCCaxz7oZPOM="
      ];
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
