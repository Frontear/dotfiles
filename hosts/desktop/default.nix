{ nixos-hardware, ... }: {
    imports = [
        ../common

        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.common-pc-ssd

        ./hardware-configuration.nix
        ./configuration.nix
    ];
}
