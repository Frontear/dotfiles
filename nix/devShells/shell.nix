{
  mkShellNoCC,

  packages ? [],
}:
mkShellNoCC {
  inherit packages;
}
