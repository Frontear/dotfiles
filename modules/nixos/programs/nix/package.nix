{
  callPackage,
  buildEnv,

  nix,
}:
let
  wrapper = callPackage ./wrapper { inherit nix; };
in buildEnv {
  inherit (nix) name;

  paths = [
    wrapper
    nix
  ];

  ignoreCollisions = true;
  extraOutputsToInstall = nix.meta.outputsToInstall;
  meta.mainProgram = "nix";
}
