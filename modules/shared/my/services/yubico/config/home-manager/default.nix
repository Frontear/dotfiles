{
  nixosConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.my.services.yubico;

  # Temporary extension to `pkgs` to fix an upstream incompatibility between
  # `yubikey-manager` and `yubioath-flutter`.
  #
  # TODO: drop with https://github.com/NixOS/nixpkgs/issues/442315
  pkgs' = pkgs.extend (final: prev: {
    # from: https://github.com/NixOS/nixpkgs/blob/3a75333d2d9e9114e0d8223f8bcd9d3b32c6401f/pkgs/by-name/yu/yubikey-manager/package.nix
    yubikey-manager = prev.callPackage ./yubikey-manager.nix {};
  });
in {
  config = lib.mkIf cfg.enable {
    my.persist.directories = [
      {
        path = "~/.local/share/com.yubico.yubioath";
        unique = true;
      }
      {
        path = "~/.local/share/ykman";
        unique = true;
      }
    ];

    home.packages = with pkgs'; [
      yubikey-manager
      yubioath-flutter
    ];

    programs.gpg.scdaemonSettings = lib.mkIf config.my.programs.gnupg.enable {
      # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
      disable-ccid = true;
    };
  };
}