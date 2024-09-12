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
      # Ensure /var/tmp is a persisted directory (all of var should be persisted anyways)
      # TODO: move this to saner place
      my.persist.directories = [ "/var/tmp" ];

      # Encourage Nix to use the (usually larger) /var/tmp instead of /tmp
      systemd.services.nix-daemon = {
        environment.TMPDIR = "/var/tmp";
      };
    }
    {
      # Disable the legacy channels
      nix.channel.enable = lib.mkForce false;

      # Use Lix!
      # https://gist.github.com/Frontear/f88e27b0a5c2841c849a1a21e6b70793
      nix.package = pkgs.lix;

      # Use viper's nix wrapper
      programs.nh.enable = true;
    }
    {
      # Explicitly set NIX_PATH in both locations, because they don't
      # correctly propagate if channels are disabled.
      # https://github.com/NixOS/nixpkgs/pull/273170
      nix.nixPath = lib.mkForce [ "${inputFarm}" ];
      nix.settings.nix-path = lib.mkForce config.nix.nixPath;

      # Disable the default nix registry and propagate it
      # with our inputs.
      nix.settings.flake-registry = lib.mkForce "";
      nix.registry = lib.mapAttrs' (name: val: {
        inherit name;
        value.flake = val;
      }) inputs;
    }
    {
      # Configure nixpkgs with opinionated settings.
      # https://nixos.org/manual/nixpkgs/unstable/#chap-packageconfig
      nixpkgs.config = {
        allowUnfree = true;
        checkMeta = true;
        warnUndeclaredOptions = true;
      };
    }
    {
      # Configure nix with opinionated settings.
      nix.settings = lib.mkMerge (import ./settings.nix);
    }
  ]);
}
