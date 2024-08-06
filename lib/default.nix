lib:
let
  inherit (builtins)
    baseNameOf
    concatLists
    map
    substring
    toString
    ;

  inherit (lib)
    filter
    isStringLike
    listToAttrs
    mergeEqualOption
    mkOptionType
    nixosSystem
    ;

  inherit (lib.filesystem)
    listFilesRecursive
    ;
in {
  /*
    Returns a list of files from the current directory and recursively down
    the directory tree, such that their file name does NOT qualify the predicate
    provided.

    This function is only intended to recursively populate the `imports` in
    the context of the module system. It also excludes the path's default.nix,
    as it would result in a stack overflow if it wasn't (in some cases).

    Example:
      - importsRecursive ./. (x: x != "default.nix") # Returns all files that are not named "default.nix"
      - importsRecursive ./. (x: x == "default.nix") # Returns all files named "default.nix"
  */
  importsRecursive = (path: pred:
    filter (x:
      # We need to exclude the path's default.nix for situations where this is called from the default.nix of said path, else it will infrec
      x != path + /default.nix &&
      pred (baseNameOf x)
    )
    (listFilesRecursive path)
  );

  flake = {
    # Exposes nixosConfigurations in a slightly
    # more declarative manner, handling system
    # as well as hostName, which ensures consistency
    # across the flake and configurations.
    #
    # e.g.
    # mkHostConfigurations "aarch64" [{
    #   hostName = "LAPTOP-3DT4F02";
    #   modules = [
    #     ../hosts/laptop
    #   ];
    # }];
    #
    # This will result in:
    # LAPTOP-3DT4F02 = nixosSystem {
    #   modules = [
    #     ../hosts/laptop
    #   ];
    # };
    mkHostConfigurations = (system: configuration-list:
      # This function expects [{ name; value; }] pairings,
      # so we map our inputted list accordingly.
      listToAttrs (
        map (x:
          {
            name = x.hostName;
            value = nixosSystem ({
              modules = concatLists [
                [{
                  # Set these here for consistency between
                  # flake and configurations
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
