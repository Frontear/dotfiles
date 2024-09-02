{
  self,
  inputs,
  lib,
  ...
}:
{
  flake = {
    cachixJobs = (with lib; genAttrs (attrNames self.nixosConfigurations) (host:
    let
      # We want an instance of pkgs that has host-specific config and overlays applied
      pkgs = self.nixosConfigurations.${host}.pkgs;
    in pkgs.linkFarmFromDrvs "cachix-${host}" (
      # for modules/system/desktops/cosmic
      #
      # We want to source these from the exact nixpkgs instance that the hosts use. This is
      # because nixos-cosmic uses an overlay, which taints nixpkgs and forces a rebuild at
      # build-time. To prevent that we use the same instance, ensuring reproducibility on
      # that specific host.
      (attrValues (genAttrs (attrNames inputs.nixos-cosmic.packages.${pkgs.system}) (name: pkgs.${name}))) ++

      # for modules/system
      (pipe self.nixosConfigurations.${host}.config.my.system [
        attrValues
        (filter (x: x ? package))
        (map (x: x.package))
      ]) ++

      # for modules/users
      (pipe self.nixosConfigurations.${host}.config.my.users [
        attrValues
        (map (x: attrValues x.programs))
        concatLists
        (filter (x: x ? package))
        (map (x: x.package))
      ])
    )));
  };
}
