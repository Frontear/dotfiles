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
      scripts =
        self'.packages
        |> lib.attrVals [
          "nix-benchmark"
          "nixos-clean"
          "nixos-rollback"
          "update-dotfiles"
        ];
    };
  };
}