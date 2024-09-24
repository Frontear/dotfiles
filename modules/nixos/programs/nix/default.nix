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
      # Use viper's nix cli wrapper, use Lix instead of Nix,
      # and wrap /bin/nix to have it use my fast-repl
      programs.nh.enable = true;

      nix.package = pkgs.lix;
      environment.systemPackages = lib.singleton (pkgs.callPackage ./fast-repl/package.nix { nix-package = config.nix.package; });
    }
    {
      # Disable the legacy channels, set nix path to fix breakages from
      # doing so, and get rid of the stinky flake registry to populate it
      # with out own stuff.
      nix.channel.enable = lib.mkForce false;

      nix.nixPath = lib.mkForce [ "${inputFarm}" ];
      nix.settings.nix-path = lib.mkForce config.nix.nixPath;

      nix.settings.flake-registry = lib.mkForce "";
      nix.registry = lib.mapAttrs' (name: val: {
        inherit name;
        value.flake = val;
      }) inputs;
    }
    {
      # Configure nix and nixpkgs with opinionated settings.
      # see (nixpkgs): https://nixos.org/manual/nixpkgs/unstable/#chap-packageconfig
      nix.settings = lib.mkMerge (import ./settings.nix);
      nixpkgs.config = {
        allowUnfree = true;
        checkMeta = true;
        warnUndeclaredOptions = true;
      };
    }
  ]);
}
