{
  callPackage,
  buildEnv,

  app2unit,
}:
let
  wrapper = callPackage ./package.nix {
    inherit app2unit;
  };
in buildEnv {
  inherit (app2unit) name version;

  paths = [
    wrapper
    app2unit
  ];

  ignoreCollisions = true;
  meta.mainProgram = "app2unit";
}