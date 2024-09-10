{
  self,
  lib,
  ...
}:
{
  flake = {
    cachixJobs = (with lib; mapAttrs (name: value:
    let
      inherit (value) config pkgs;
    in pkgs.linkFarmFromDrvs "cachix-${name}" (
      # for modules/nixos
      (pipe config.my [
        attrValues
        (filter (x: x ? package))
        (map (x: x.package))
      ]) ++

      # for modules/home-manager
      (pipe config.home-manager.users [
        attrValues
        (map (x: attrValues x.my.programs))
        concatLists
        (filter (x: x ? package))
        (map (x: x.package))
      ])
    )) self.nixosConfigurations);
  };
}