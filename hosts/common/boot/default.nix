{ ... }: {
  imports = [
    ./cpu-microcode.nix
    ./fast-compressor.nix
    ./silent-process.nix
    ./systemd-stage2.nix
  ];
}
