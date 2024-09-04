{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf mkMerge;

  attrs = {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    my.system.audio.pipewire.enable = mkDefault true;
  };
in {
  imports = [
    inputs.nixos-cosmic.nixosModules.default
  ];

  options.my.system.desktops.cosmic = {
    enable = mkEnableOption "cosmic";

    default = mkEnableOption "make default";
  };

  config = mkIf config.my.system.desktops.cosmic.enable (mkMerge [
    (mkIf config.my.system.desktops.cosmic.default ({
      assertions = [
        {
          assertion = !config.my.system.desktops.plasma.default;
          message = "Cosmic and Plasma cannot both be default.";
        }
        {
          assertion = !config.my.system.desktops.sway.default;
          message = "Cosmic and Sway cannot both be default.";
        }
      ];
    } // attrs))
    (mkIf (!config.my.system.desktops.cosmic.default) {
      specialisation.cosmic.configuration = attrs;
    })
  ]);
}
