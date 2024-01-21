{ ... }: {
  imports = [
    ./mounts.nix
    ./unfree.nix

    ./boot
    ./flakes
    ./network
    ./zram
  ];
}
