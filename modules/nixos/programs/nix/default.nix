{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  # thanks lychee :3
  # https://github.com/itslychee/config/blob/69290575cc0829d40b516654e19d6b789edf32d0/modules/nix/settings.nix
  inputFarm = pkgs.linkFarm "input-farm" (lib.mapAttrsToList (name: path: {
    inherit name path;
  }) inputs);
in {
  config = lib.mkIf config.nix.enable (lib.mkMerge [
    {
      # Use github:viperML/nh as our "nix wrapper" program.
      programs.nh.enable = true;

      # Wrap the official nix binary with a snippet to allow
      # rapid repl access to `pkgs.*` and `lib.*` attributes.
      nix.package = pkgs.callPackage ./package.nix { nix = pkgs.lix; };
    }
    {
      # Throttle the nix-daemon so it doesn't consume
      # all of our systems' available memory. This
      # functionality leverages cgroupsv2.
      #
      # The logic here is that relying on swap more
      # will reduce the likelihood of an OOM condition
      # and overall reduce extreme freezing on our system.
      nix.settings = {
        experimental-features = lib.singleton "cgroups";
        use-cgroups = true;
      };

      systemd.services.nix-daemon.serviceConfig = {
        MemoryHigh = "70%";
        MemorySwapMax = "90%";
      };

      # TODO: determine the usefulness of these
      # from: https://github.com/nix-community/servos/blob/c98d0acb7c447a85f9f3d751321e9012ea21e8e1/nixos/common/nix.nix
      nix.daemonCPUSchedPolicy = "batch";
      nix.daemonIOSchedClass = "idle";
      nix.daemonIOSchedPriority = 7;
    }
    {
      # Configure nixpkgs with some sane defaults that will
      # propagate throughout the configuration.
      # see: https://nixos.org/manual/nixpkgs/unstable/#chap-packageconfig
      nixpkgs.config = {
        allowUnfree = true;
        checkMeta = true;
        warnUndeclaredOptions = true;
      };
    }
    {
      # Disable the legacy channels and set nix path to fix
      # breakages from doing so.
      nix.channel.enable = lib.mkForce false;
      
      nix.nixPath = lib.mkForce [ "${inputFarm}" ];
      nix.settings.nix-path = lib.mkForce config.nix.nixPath;
    }
    {
      # Fully replace the flake registry with relevant inputs.
      nix.settings.flake-registry = lib.mkForce "";
      nix.registry = lib.mapAttrs' (name: val: {
        inherit name;
        value.flake = val;
      }) inputs;
    }
    {
      # Configure the nix daemon with some opinionated defaults.
      # see: https://nix.dev/manual/nix/development/command-ref/conf-file.html
      nix.settings = lib.mkMerge [
        {
          # Leverage my custom substituters, courtesy of Cachix.
          substituters = lib.singleton "https://frontear.cachix.org";
          trusted-public-keys = lib.singleton "frontear.cachix.org-1:rrVt1C9dFaJf9QpG1Vu6sHqEUy0Q8ezLCCaxz7oZPOM=";
        }
        {
          allow-import-from-derivation = false;
          auto-optimise-store = true;

          builders-use-substitutes = true;

          connect-timeout = 15;
          cores = 0;

          debugger-on-trace = true;
          # debugger-on-warn = true;
          download-attempts = 3;
          eval-cache = true;

          # It's useful to know when a substitute is failing!
          fallback = false;

          # Improve the chances of the store surviving a random crash.
          fsync-metadata = true;
          # fsync-store-paths = true;

          # Keeping these is very useful for development.
          keep-build-log = true;
          keep-derivations = true;
          keep-failed = true;
          keep-outputs = true;

          max-jobs = "auto";
          min-free = 10 * 1024 * 1024 * 1024;

          preallocate-contents = true;

          # Never allow a non-sandboxed build
          sandbox-fallback = false;

          show-trace = true;
          sync-before-registering = true;

          trace-verbose = true;
          trusted-users = [
            "root"
            "@wheel"
          ];

          use-xdg-base-directories = true;

          # This is such a silly warning.
          warn-dirty = false;
        }
        {
          # Disallow flake configs by default, and enable automatic
          # UID allocation as required by the nix builder.
          accept-flake-config = false;
          auto-allocate-uids = true;

          # Enable relevant experimental features that are used
          # by this configuration.
          experimental-features = [
            # Relevant for building.
            "auto-allocate-uids"

            # Critical flags for flakes.
            "flakes"
            "nix-command"
            
            # Some interesting features.
            # "fetch-closures"
            "no-url-literals"
          ];
        }
      ];
    }
  ]);
}
