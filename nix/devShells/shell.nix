{
  mkShellNoCC,

  introduce-bin,
  nix-benchmark,
  nixos-clean,
}:
mkShellNoCC {
  packages = [
    introduce-bin
    nix-benchmark
    nixos-clean
  ];
}
