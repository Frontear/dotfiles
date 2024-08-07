# https://nix.dev/manual/nix/development/command-ref/conf-file.html
[
  {
    # Set my custom substituters courtesy of cachix.
    substituters = [
      "https://frontear.cachix.org"
    ];
    trusted-public-keys = [
      "frontear.cachix.org-1:rrVt1C9dFaJf9QpG1Vu6sHqEUy0Q8ezLCCaxz7oZPOM="
    ];
  }
  {
    # Enable an experimental feature that creates builders
    # for nix on the fly.
    auto-allocate-uids = true;
    experimental-features = [
      "auto-allocate-uids"
    ];
  }
  {
    # Leverages cgroups during the nix building process
    use-cgroups = true;
    experimental-features = [
      "cgroups"
    ];
  }
  {
    accept-flake-config = false;
    allow-import-from-derivation = false;
    auto-optimise-store = true;
    bash-prompt-prefix = "(devshell) ";
    cores = 0;
    eval-cache = false; # this stinks!
    experimental-features = [
      "flakes"
      "nix-command"
      "no-url-literals"
    ];
    fallback = true;
    http-connections = 0;
    log-lines = 50;
    max-jobs = "auto";
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
    use-registries = true;
    use-xdg-base-directories = true;
  }
]