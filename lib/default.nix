{
  self,
}:
_: prev:
let
  callLib = file: import file {
    inherit self;
    lib = prev;
  };

  self' = {
    flakes = callLib ./flakes.nix;

    options = callLib ./options.nix // prev.options;
    path = callLib ./path.nix // prev.path;
    types = callLib ./types.nix // prev.types;


    inherit (self'.flakes)
      mkModules
      mkNixOSConfigurations
      mkPackages
      stripSystem
      ;

    inherit (self'.options)
      mkDefaultEnableOption
      ;
  };
in
  self'
