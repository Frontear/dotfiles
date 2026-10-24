{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.documentation.man;

  # TODO: remove after the `linux-manual` build issue is fixed.
  #
  # see: https://github.com/NixOS/nixpkgs/issues/577968
  linux-manual' = pkgs.linux-manual.overrideAttrs {
    env = {
      # Same fallback that is used in `tools/docs/sphinx-build-wrapper`.
      srctree = ".";
    };
  };
in {
  config = lib.mkIf cfg.enable {
    # I find these the man pages from these two to be quite useful to view.
    # They usually exist on most other distros, and I'm very used to that
    # availability, so let's bring them back here too.
    environment.systemPackages = with pkgs; [
      linux-manual'
      man-pages
    ];
  };
}