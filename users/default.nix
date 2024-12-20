{
  lib,
  ...
}:
let
  usersAttr = builtins.readDir ./.
  |> lib.filterAttrs (name: _: name != "default.nix")
  |> lib.mapAttrs (name: _: {
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
  });
in {
  imports = lib.mapAttrsToList (_: value: value.nixos) usersAttr;

  config = {
    home-manager.users = lib.mapAttrs (_: value: value.home) usersAttr;
  };
}
