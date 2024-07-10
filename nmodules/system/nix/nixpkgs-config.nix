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
      allowAliases = false;
      allowUnfree = true;
      checkMeta = true;
      showDerivationWarnings = [
        "maintainerless"
      ];
      warnUndeclaredOptions = true;
    };
  };
}