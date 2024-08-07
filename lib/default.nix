{
  self,
  lib,
}:
let
  inherit (builtins)
    baseNameOf
    filter
    substring
    toString
    ;

  inherit (lib)
    isStringLike
    mergeEqualOption
    mkOptionType
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
