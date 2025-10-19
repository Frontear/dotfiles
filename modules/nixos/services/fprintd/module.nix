{
  config,
  lib,
  ...
}:
let
  cfg = config.services.fprintd;

  cfg-gdm = config.services.displayManager.gdm;
  cfg-greetd = config.services.greetd;
in {
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      my.persist.directories = [{
        path = "/var/lib/fprint";
        unique = false;
      }];
    }

    # Prevent fingerprint login, as it breaks UX expectations and has no
    # straightforward solution.
    #
    # NOTE: this isn't unique to GDM, despite the issue being filed there.
    # see: https://gitlab.gnome.org/GNOME/gdm/-/issues/613
    {
      programs.dconf.profiles = lib.mkIf cfg-gdm.enable {
        gdm.databases = [{
          lockAll = true;

          settings = {
            "org/gnome/login-screen" = {
              enable-fingerprint-authentication = false;
            };
          };
        }];
      };

      security.pam.services = lib.mkMerge [
        { "login".fprintAuth = false; }

        (lib.mkIf cfg-greetd.enable {
          "greetd".fprintAuth = false;
        })
      ];
    }
  ]);
}