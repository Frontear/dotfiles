{
  self,
  inputs,
  lib,
  ...
}:
{
  flake = {
    cachixJobs = (with lib; mapAttrs (name: value:
    let
      inherit (value) config pkgs;
    in pkgs.linkFarmFromDrvs "cachix-${name}" (
      # for modules/system/desktops/cosmic
      #
      # We want to source these from the exact nixpkgs instance that the hosts use. This is
      # because nixos-cosmic uses an overlay, which taints nixpkgs and forces a rebuild at
      # build-time. To prevent that we use the same instance, ensuring reproducibility on
      # that specific host.
      (pipe inputs.nixos-cosmic.packages.${pkgs.system} [
        (mapAttrsToList (name: _: pkgs.${name}))
      ]) ++

      # for modules/system
      (pipe config.my.system [
        attrValues
        (filter (x: x ? package))
        (map (x: x.package))
      ]) ++

      # for modules/users
      (pipe config.my.users [
        attrValues
        (map (x: attrValues x.programs))
        concatLists
        (filter (x: x ? package))
        (map (x: x.package))
      ])
    )) self.nixosConfigurations);
  };
}
