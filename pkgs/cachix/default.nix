{
  self,
  lib,
}:
# recursively update, as hosts may share a system
(with lib; foldr recursiveUpdate {} (attrValues (mapAttrs (name: value:
let
  inherit (value) config pkgs;
in {
  # map to system.name for flake schema
  ${pkgs.system}.${name} = pkgs.linkFarmFromDrvs "cachix-${name}" (
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
  );
}) self.nixosConfigurations)))
