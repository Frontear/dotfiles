{
  ...
}:
{
  perSystem = { self', pkgs, ... }: {
    devShells.default = pkgs.callPackage ./shell.nix {
      introduce-bin = pkgs.callPackage ./bin {};
      inherit (self'.packages) nixos-clean;
    };
  };
}
