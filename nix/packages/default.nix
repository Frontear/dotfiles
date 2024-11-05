{
  self,
  ...
}:
let
  inherit (self) lib;
in {
  imports = [
    ./cachix.nix
  ];

  perSystem = { pkgs, ... }: {
    packages = lib.pipe ../../pkgs [
      lib.filesystem.listFilesRecursive
      (lib.filter (lib.hasSuffix "package.nix"))
      (map (drv: rec {
        name = value.pname;
        value = pkgs.callPackage drv {};
      }))
      lib.listToAttrs
    ];
  };
}
