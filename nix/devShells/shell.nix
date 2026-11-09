{
  mkShellNoCC,

  nixd,

  scripts ? [],
}:
mkShellNoCC {
  packages = scripts ++ [
    nixd
  ];
}