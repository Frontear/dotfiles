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
    # https://nixos.org/manual/nixpkgs/unstable/#chap-packageconfig
    nixpkgs.config = {
      allowAliases = true; # TODO: pkgs.system no worky
      allowUnfree = true;
      checkMeta = true;
      warnUndeclaredOptions = true;
    };
  };
}