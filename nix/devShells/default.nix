{
  lib,
  ...
}:
{
  imports = [
    ./per-package.nix
  ];

  perSystem = { self', pkgs, ... }: {
    devShells.default = pkgs.callPackage ./shell.nix {
      packages =
        self'.packages
        |> lib.attrVals [
          "nix-benchmark"
          "nixos-clean"
          "nixos-rollback"
        ];
    };
  };
}
