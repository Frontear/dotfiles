{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.libimobiledevice;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ifuse
      idevicerestore
      libimobiledevice
    ];

    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };

    # TODO: remove this when nixos-unstable has the PR
    #
    # see: https://github.com/NixOS/nixpkgs/pull/419291
    nixpkgs.overlays = [
      (final: prev: {
        libirecovery = prev.libirecovery.overrideAttrs {
          configureFlags = [
            "--with-udevrulesdir=${placeholder "out"}/lib/udev/rules.d"
            ''--with-udevrule=OWNER="root",GROUP="myusergroup",MODE="0660"''
          ];
        };
      })
    ];
  };
}
