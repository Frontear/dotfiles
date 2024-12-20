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
        # For modules/nixos
        (lib.attrValues value.config.my
        |> lib.filter (x: x ? package)
        |> map (x: x.package))
        ++ 
        # For modules/home-manager
        (lib.attrValues value.config.home-manager.users
        |> map (x: lib.attrValues x.my.programs)
        |> lib.concatLists
        |> lib.filter (x: x ? package)
        |> map (x: x.package))
      )
    );
  };
}
