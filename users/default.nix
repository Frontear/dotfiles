{
  lib,
  ...
}:
let
  allUsers = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.mapAttrsToList (name: _: {
      inherit name;

      system = ({
        imports = [
          ./${name}/system
        ];

        users.extraUsers.${name} = {
          inherit name;
          home = "/home/${name}";

          isNormalUser = true;
        };
      });

      home = ({
        imports = [
          ./${name}/home
        ];

        home = {
          username = name;
          homeDirectory = "/home/${name}";
        };
      });
    }))
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