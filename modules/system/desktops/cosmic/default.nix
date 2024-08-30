{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
in {
  imports = [
    inputs.nixos-cosmic.nixosModules.default
  ];

  options.my.system.desktops.cosmic.enable = mkEnableOption "cosmic";

  config = mkIf config.my.system.desktops.cosmic.enable {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    my.system.audio.pipewire.enable = mkDefault true;

    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };
  };
}