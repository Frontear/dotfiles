{
  final,
  prev,

  self,
}:
{
  mkDefaultEnableOption = (name:
    (final.mkEnableOption name) // { default = true; }
  );

  mkModules = (modulesPath: { ... } @ extraArgs: {
    imports = final.pipe modulesPath [
      final.filesystem.listFilesRecursive
      (final.filter (final.hasSuffix "module.nix"))
      (map (mod:
      let
        imported = import mod;
      in {
        # args = { config, lib, modulesPath, options, pkgs, ... }
        __functor = _: args: imported (args // extraArgs);
        __functionArgs = final.functionArgs imported;
      }))
    ];
  });
                                                                                      
  mkNixOSConfigurations = (system: list: final.pipe list [
    (map ({ hostName, modules, ... } @ extraArgs: {
      name = hostName;
      value = final.nixosSystem {
        specialArgs = {
          # self = flake.stripSystem system self;
        } // (if extraArgs ? specialArgs then extraArgs.specialArgs else {});
                                                                                      
        modules = [
          (self.nixosModules.default or {})
          {
            networking.hostName = hostName;
            nixpkgs.hostPlatform = system;
          }
        ] ++ modules;
      } // (removeAttrs extraArgs [ "hostName" "modules" "specialArgs" ]);
    }))
    final.listToAttrs
  ]);

  mkPackages = (pkgs: pkgsPath: final.pipe pkgsPath [
    final.filesystem.listFilesRecursive
    (final.filter (final.hasSuffix "package.nix"))
    (map (drv: rec {
      name = final.getName value;
      value = pkgs.callPackage drv {};
    }))
    final.listToAttrs
  ]);
                                                                                      
  stripSystem = (system: flake:
  let
    removeSystemAttr = final.mapAttrs (_: v: if v ? ${system} then v.${system} else v);
    outputsToRemove = [ "inputs" "outputs" "sourceInfo" ];
  in (removeSystemAttr (removeAttrs flake outputsToRemove)));

  types = rec {
    systemPath = prev.types.path;
    userPath = prev.types.either systemPath (prev.types.strMatching "~/.+");
  } // prev.types;
}
