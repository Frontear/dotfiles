{
  lib,
  ...
}:
let
  splitList = map (path:
    lib.splitString "/" path
    |> lib.filter (x: x != "")
  );

  joinAttrs = (delim: attrs: (map (n:
    if attrs.${n} == null then
      "${delim}${n}"
    else
      joinAttrs "${delim}${n}/" attrs.${n}
  ) (lib.attrNames attrs)));

  self' = {
    clobber = paths:
      splitList paths
      |> lib.sort (e1: e2: lib.length e1 > lib.length e2)
      |> map (path: lib.setAttrByPath path null)
      |> lib.foldl lib.recursiveUpdate {}
      |> joinAttrs "/"
      |> lib.flatten;
  };
in
  self'
