{
  lib,
  ...
}:
let
  allUsers = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.mapAttrsToList (name: _: { inherit name; system = ./${name}/system; home = ./${name}/home; }))
  ];

  mkUsers = ({
    imports = map (u: u.system) allUsers;

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users = lib.listToAttrs (map (u: { inherit (u) name; value = u.home; }) allUsers);
    };
  });
in mkUsers