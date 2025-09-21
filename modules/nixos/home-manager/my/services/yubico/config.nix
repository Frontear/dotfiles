{
  nixosConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.my.services.yubico;
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

    home.packages = with pkgs; [
      yubikey-manager
      yubioath-flutter
    ];

    programs.gpg.scdaemonSettings = lib.mkIf config.my.programs.gnupg.enable {
      # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
      disable-ccid = true;
    };
  };
}