{
  mkShellNoCC,

  introduce-bin,
  nix-benchmark,
  nixos-clean,
  nixos-rollback,
}:
mkShellNoCC {
  packages = [
    introduce-bin
    nix-benchmark
    nixos-clean
    nixos-rollback
  ];
}
