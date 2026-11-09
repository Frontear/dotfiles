{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.defaults;
in {
  config = lib.mkIf cfg.enable {
    # Default keymap, locale, and time zone
    console.keyMap = "us";
    i18n.defaultLocale = "en_CA.UTF-8";
    time.timeZone = "America/Toronto";

    # XanMod kernel has Clear Linux patches
    #
    # TODO: remove when #584576 lands in unstable
    # see: https://github.com/NixOS/nixpkgs/pull/584576
    boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linuxKernel.kernels.linux_xanmod_latest.override (prev: {
      argsOverride = {
        kernelPatches = lib.filter (x: x.name != "tools-add-128-bit-integer-types-for-aarch64") prev.kernelPatches;
      };
    }));
  };
}