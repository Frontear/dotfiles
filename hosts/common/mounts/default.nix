{ ... }: {
  imports = [
    ./archive-mount.nix
    ./boot-mount.nix
    ./with-impermanence.nix
    ./without-impermanence.nix
  ];
}
