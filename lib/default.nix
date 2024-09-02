{
  self,
  lib,
}:
let
  inherit (builtins)
    baseNameOf
    filter
    mapAttrs
    listToAttrs
    removeAttrs
    substring
    toString
    ;

  inherit (lib)
    functionArgs
    isStringLike
    mergeEqualOption
    mkOptionType
    nixosSystem
    pipe
    ;

  inherit (lib.filesystem)
    listFilesRecursive
    ;
in rec {
  flake = {
    mkModules = (path: { ... } @ extraArgs: {
      imports = pipe path [
        listFilesRecursive
        (filter (x: baseNameOf x == "default.nix"))
        (map (x:
        let
          imported = import x;
        in {
          # args = { config, lib, modulesPath, options, pkgs, ... }
          __functor = _: args: imported (args // extraArgs);
          __functionArgs = functionArgs imported;
        }))
      ];
    });

    mkNixOSConfigurations = (system: list: pipe list [
      (map ({ hostName, modules, ... } @ extraArgs: {
        name = hostName;
        value = nixosSystem {
          specialArgs = {
            self = flake.mkSelf' system;
          } // (if extraArgs ? specialArgs then extraArgs.specialArgs else {});

          modules = [
            self.nixosModules.default
            {
              networking.hostName = hostName;
              nixpkgs.hostPlatform = system;
            }
          ] ++ modules;
        } // (removeAttrs extraArgs [ "hostName" "modules" "specialArgs" ]);
      }))
      listToAttrs
    ]);

    # TODO: better name?
    mkSelf' = (system:
    let
      removeSystemAttr = mapAttrs (_: v: if v ? ${system} then v.${system} else v);
      outputsToRemove = [ "outputs" "sourceInfo" ];
    in (removeSystemAttr (removeAttrs self outputsToRemove)) // {
      inputs = mapAttrs (_: v: removeSystemAttr (removeAttrs v ([ "inputs" ] ++ outputsToRemove))) self.inputs;
    });
  };

  types =
  let
    mkPathOption = name: end: mkOptionType {
      inherit name;
      description = "absolute path, denoted with a ${end}";
      descriptionClass = "nonRestrictiveClause";
      check = (x:
        isStringLike x &&
        substring 0 1 (toString x) == end
      );
      merge = mergeEqualOption;
    };
  in {
    systemPath = mkPathOption "systemPath" "/";
    userPath = mkPathOption "userPath" "~";
  } // lib.types;
}
