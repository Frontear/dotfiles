{
  self,
  lib,
  ...
}:
{
  perSystem = { pkgs, ... }: {
    packages = self.nixosConfigurations
      |> lib.filterAttrs (_: value: value.pkgs.system == pkgs.system)
      |> lib.mapAttrs (name: value: pkgs.linkFarmFromDrvs "cachix-${name}" (
        value.config.my.toplevel.cachix
      )
    );
  };
}
