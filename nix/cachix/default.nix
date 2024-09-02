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
      inputFarm = (inputs:
      let
        isTrivial = input: !isType "flake" input || input.inputs == {};
        mkDrv = name: path: pkgs.linkFarm "input-${name}-${toString path.lastModified}" (singleton { inherit name path; });
      in pipe (removeAttrs inputs (singleton "self")) [
        (mapAttrsToList (name: path:
          if isTrivial path then
            (mkDrv name path)
          else
            ((inputFarm path.inputs) ++ (singleton (mkDrv name path)))
        ))
        flatten
      ]);
    in pkgs.linkFarmFromDrvs "cachix-${host}" (
      # self.inputs and inputs of inputs, recursively linked
      (inputFarm inputs) ++

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
