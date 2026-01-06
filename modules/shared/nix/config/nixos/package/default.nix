{
  callPackage,
  buildEnv,

  nix,
}:
let
  wrapper = callPackage ./package.nix {
    inherit nix;
  };
in buildEnv {
  inherit (nix) name pname version;

  paths = [
    wrapper
    nix
  ];

  ignoreCollisions = true;
  extraOutputsToInstall = nix.meta.outputsToInstall;
  meta.mainProgram = "nix";
}