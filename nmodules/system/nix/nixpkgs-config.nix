{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.nix.enable {
    # https://nixos.org/manual/nixpkgs/unstable/#chap-packageconfig
    nixpkgs.config = {
      allowAliases = true; # TODO: pkgs.system no worky
      allowUnfree = true;
      checkMeta = true;
      warnUndeclaredOptions = true;
    };
  };
}