{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.services.yubico;
in {
  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = osConfig.my.services.yubico.enable;
      message = "Please enable my.services.yubico in your NixOS configuration";
    }];


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