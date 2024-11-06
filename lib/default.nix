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
      (final.filter (final.hasSuffix "default.nix"))
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

  types = (
  let
    mkPathOption = { name, prefix }: prev.mkOptionType {
      inherit name;
      description = "An absolute path, prefixed with ${prefix}.";
      descriptionClass = "nonRestrictiveClause";
                                                                
      check = (x:
        prev.isStringLike x &&
        prev.substring 0 1 x == prefix
      );
      merge = prev.mergeEqualOption;
    };
  in {
    systemPath = mkPathOption {
      name = "systemPath";
      prefix = "/";
    };
                                                                
    userPath = mkPathOption {
      name = "userPath";
      prefix = "~";
    };
  } // prev.types);
}
