{
  self,
  lib,
}:
let
  inherit (builtins)
    baseNameOf
    concatLists
    filter
    listToAttrs
    map
    mapAttrs
    removeAttrs
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
in {
  importsRecursive = (path: pred:
    filter (x:
      # TODO: don't assume default.nix is caller
      x != path + /default.nix &&
      pred (baseNameOf x)
    )
    (listFilesRecursive path)
  );

  flake = {
    mkHostConfigurations = (system: configuration-list:
      listToAttrs (
        map (x:
          {
            name = x.hostName;
            value = nixosSystem ({
              specialArgs = {
                # TOOD: move?
                self = mapAttrs (_: value:
                  if value ? ${system} then value.${system} else value
                ) (removeAttrs self [ "outputs" ]);
              };
              modules = concatLists [
                [{
                  networking.hostName = x.hostName;
                  nixpkgs.hostPlatform = system;
                }]
                x.modules
              ];
            });
          }
        ) configuration-list
      )
    );
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
