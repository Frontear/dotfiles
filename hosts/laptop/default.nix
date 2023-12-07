{ nixos-hardware, ... }: {
    imports = [
        ../common

        nixos-hardware.nixosModules.dell-inspiron-14-5420
        nixos-hardware.nixosModules.common-cpu-intel-cpu-only
        nixos-hardware.nixosModules.common-gpu-intel
        nixos-hardware.nixosModules.common-hidpi
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd

        ./hardware-configuration.nix
        ./configuration.nix
    ];
}
