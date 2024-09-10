{
  lib,
  ...
}:
let
  mkPathOption = { name, prefix }: lib.mkOptionType {
    inherit name;
    description = "An absolute path, prefixed with ${prefix}.";
    descriptionClass = "nonRestrictiveClause";
                                                                
    check = (x:
      lib.isStringLike x &&
      lib.substring 0 1 x == prefix
    );
    merge = lib.mergeEqualOption;
  };
in {
  systemPath = mkPathOption {
    name = "systemPath";
    prefix = "/";
  };
                                                                
  userPath = mkPathOption {
    name = "userPath";
    prefix = "~";
  };
}
