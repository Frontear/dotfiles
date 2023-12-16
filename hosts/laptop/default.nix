{
    inputs,
    ...
}:
let
    nix-hw = inputs.nixos-hardware.nixosModules;
in {
    imports = [
        ./hardware-configuration.nix

        nix-hw.dell-inspiron-14-5420
        nix-hw.common-cpu-intel
        nix-hw.common-hidpi
        nix-hw.common-pc-laptop
        nix-hw.common-pc-ssd

        inputs.home-manager.nixosModules.default
        inputs.impermanence.nixosModules.impermanence

        ./configuration.nix
    ];
}
