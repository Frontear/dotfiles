{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.documentation.man;
in {
  config = lib.mkIf cfg.enable {
    # I find these the man pages from these two to be quite useful to view.
    # They usually exist on most other distros, and I'm very used to that
    # availability, so let's bring them back here too.
    environment.systemPackages = with pkgs; [
      # Something changed in the `linux-manual` build, and the fix PR hasn't
      # laned in unstable, so we pull it here.
      #
      # TODO: drop this fix once the relevant PR is merged
      # see: https://github.com/NixOS/nixpkgs/issues/489956
      (callPackage ./package.nix {})
      man-pages
    ];
  };
}