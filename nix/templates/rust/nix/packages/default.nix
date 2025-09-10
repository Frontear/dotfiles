{
  ...
}:
{
  perSystem = { pkgs, ... }: {
    packages.default = pkgs.callPackage ./package.nix {};
  };
}
