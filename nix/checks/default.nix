{
  self,
  lib,
  ...
}:
{
  perSystem = { self', pkgs, ... }: {
    checks = {
      devShells = (pkgs.linkFarm "all-devShells" (
        self'.devShells
        |> lib.mapAttrsToList (name: value: {
          inherit name;
          path = value;
        })
      ));

      nixosConfigurations = (pkgs.linkFarm "all-nixosConfigurations" (
        self.nixosConfigurations
        |> lib.filterAttrs (_: value:
          value.pkgs.stdenv.hostPlatform == pkgs.stdenv.hostPlatform
        )
        |> lib.mapAttrs (_: value: value.config.system.build)
        |> lib.mapAttrsToList (name: value: {
          inherit name;
          path = value.isoImage or value.toplevel;
        })
      ));

      # TODO: add nixosModules tests

      packages = (pkgs.linkFarm "all-packages" (
        self'.packages
        |> lib.mapAttrsToList (name: value: {
          inherit name;
          path = value;
        })
      ));
    };
  };
}