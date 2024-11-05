{
  mkShellNoCC,

  introduce-bin,
  nixos-clean,
}:
mkShellNoCC {
  packages = [
    introduce-bin
    nixos-clean
  ];
}
