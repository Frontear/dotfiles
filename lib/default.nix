{
  self,
  lib,
}:
let
  inherit (builtins)
    baseNameOf
    concatLists
    filter
    mapAttrs
    listToAttrs
    substring
    toString
    ;

  inherit (lib)
    isStringLike
    mergeEqualOption
    mkOptionType
    nixosSystem
    ;

  inherit (lib.filesystem)
    listFilesRecursive
    ;
in rec {
  flake = {
    mkModules = (path: {
      imports = filter (x:
        (baseNameOf x) == "default.nix"
      ) (listFilesRecursive path);
    });

    mkNixOSConfigurations = (system: list: listToAttrs (
      map (x: {
        name = x.hostName;
        value = nixosSystem {
          specialArgs = {
            self = flake.mkSelf' system;
          };
          modules = concatLists [
            [
              self.nixosModules.default
              {
                networking.hostName = x.hostName;
                nixpkgs.hostPlatform = system;
              }
            ]
            x.modules
          ];
        };
      }) list
    ));

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
