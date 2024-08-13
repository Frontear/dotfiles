{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mapAttrs' mapAttrsToList mkDefault mkEnableOption mkForce mkIf mkMerge;

  # thanks lychee :3
  # https://github.com/itslychee/config/blob/69290575cc0829d40b516654e19d6b789edf32d0/modules/nix/settings.nix
  inputFarm = pkgs.linkFarm "input-farm" (mapAttrsToList (name: path: {
    inherit name path;
  }) inputs);
in {
  options.my.system.nix.enable = (mkEnableOption "nix" // { default = true; });

  config = mkIf config.my.system.nix.enable (mkMerge [
    {
      # Enable nix (duh!) and disable channels
      nix.enable = mkDefault true;
      nix.channel.enable = mkForce false;

      # Use viper's nix wrapper
      programs.nh.enable = true;
    }
    {
      # Explicitly set NIX_PATH in both locations, because they don't
      # correctly propagate if channels are disabled.
      # https://github.com/NixOS/nixpkgs/pull/273170
      nix.nixPath = [ "${inputFarm}" ];
      nix.settings.nix-path = mkForce config.nix.nixPath;
    }
    {
      # Disable the default nix registry and propagate it
      # with our inputs.
      nix.settings.flake-registry = mkForce "";
      nix.registry = mapAttrs' (name: val: {
        inherit name;
        value.flake = val;
      }) inputs;
    }
    {
      # Configure nixpkgs with opinionated settings.
      # https://nixos.org/manual/nixpkgs/unstable/#chap-packageconfig
      nixpkgs.config = {
        allowAliases = true; # TODO: pkgs.system no worky
        allowUnfree = true;
        checkMeta = true;
        warnUndeclaredOptions = true;
      };

      # Overlay nixpkgs so that pkgs.nix => pkgs.lix
      # https://gist.github.com/Frontear/f88e27b0a5c2841c849a1a21e6b70793
      nixpkgs.overlays = [
        (final: _: {
          nix = inputs.lix.packages.${final.system}.default;
        })
      ];
    }
    {
      # Configure nix with opinionated settings.
      nix.settings = mkMerge (import ./settings.nix);
    }
  ]);
}
