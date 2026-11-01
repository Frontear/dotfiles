{
  config,
  lib,
  ...
}:
let
  cfg = config.systemd.coredump;
in {
  config = lib.mkIf cfg.enable {
    systemd.coredump = {
      settings = {
        # Disable coredump processing.
        #
        # On NixOS, this is pretty useless because nothing is compiled
        # with debug symbols, so coredumps have nothing useful in them.
        #
        # see: https://wiki.archlinux.org/title/Core_dump#Disabling_automatic_core_dumps
        # see: https://discourse.nixos.org/t/how-to-completely-disable-coredump
        Coredump = {
          Storage = "none";
          ProcessSizeMax = 0;
        };
      };
    };
  };
}