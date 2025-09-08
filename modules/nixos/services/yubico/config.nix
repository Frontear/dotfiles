{
  config,
  lib,
  ...
}:
let
  cfg = config.my.services.yubico;
in {
  config = lib.mkIf cfg.enable {
    # Needed by Yubikey programs and GnuPG
    services.pcscd.enable = true;
  };
}
