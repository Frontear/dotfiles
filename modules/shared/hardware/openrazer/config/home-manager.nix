{
  nixosConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.hardware.openrazer;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      polychromatic
    ];

    # NOTE: I am not saving `~/.local/share/openrazer` because this only
    # contains logs. Logs are not necessary to see unless there's a problem,
    # and I can look at them during the problematic run.
    my.persist.directories = [
      {
        # Stores the downloaded images of Razer devices for the UI.
        path = "~/.cache/polychromatic";
        unique = false;
      }
      {
        # DPI and polling rate are saved here, in `persistence.conf`.
        path = "~/.config/openrazer";
        unique = true;
      }
      {
        # Various UI settings, and the DPI stages (I think?).
        #
        # TODO: is this necessary to store?
        path = "~/.config/polychromatic";
        unique = true;
      }
    ];
  };
}