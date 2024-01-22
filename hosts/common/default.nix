{ ... }: {
  imports = [
    ./unfree.nix

    ./boot
    ./flakes
    ./mounts
    ./network
    ./zram
  ];
}
