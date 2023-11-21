{ ... }:
{
    imports = [
        "${builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz"}/dell/inspiron/14-5420"
        ./hardware-configuration.nix
        ./mounts.nix

        ./cpu.nix
        ./gpu.nix
        ./hardware.nix
    ];
}
