{
  ...
}:
{
  imports = [
    ./cachix
    ./nixos
  ];

  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.callPackage ./devshell { };
  };
}
