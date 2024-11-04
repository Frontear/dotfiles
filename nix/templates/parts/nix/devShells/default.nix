{
  ...
}:
{
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.callPackage ./shell.nix {};
  };
}
