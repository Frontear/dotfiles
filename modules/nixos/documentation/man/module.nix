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
      linux-manual
      man-pages
    ];
  };
}