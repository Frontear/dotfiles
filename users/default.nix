{
  lib,
  ...
}:
let
  allUsers = lib.pipe ./. [
    builtins.readDir
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.mapAttrs (name: _: {
      nixos = {
        imports = [
          ./${name}/nixos
        ];

        users.users."${name}" = {
          inherit name;
          home = "/home/${name}";

          isNormalUser = true;
        };
      };

      home = {
        imports = [
          ./${name}/home
        ];

        home = {
          username = name;
          homeDirectory = "/home/${name}";
        };
      };
    }))
  ];

  mkUsers = {
    imports = lib.mapAttrsToList (_: value: value.nixos) allUsers;

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users = lib.mapAttrs (_: value: value.home) allUsers;
    };
  };
in mkUsers
