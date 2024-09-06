{
  self,
  lib,
  ...
}:
{
  flake = {
    mkModules = (modulesPath: { ... } @ extraArgs: {
      imports = lib.pipe modulesPath [
        lib.filesystem.listFilesRecursive
        (lib.filter (x: baseNameOf x == "default.nix"))
        (map (x:
        let
          imported = import x;
        in {
          # args = { config, lib, modulesPath, options, pkgs, ... }
          __functor = _: args: imported (args // extraArgs);
          __functionArgs = lib.functionArgs imported;
        }))
      ];
    });

    mkNixOSConfigurations = (system: list: lib.pipe list [
      (map ({ hostName, modules, ... } @ extraArgs: {
        name = hostName;
        value = lib.nixosSystem {
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
      lib.listToAttrs
    ]);

    stripSystem = (system: flake:
    let
      removeSystemAttr = lib.mapAttrs (_: v: if v ? ${system} then v.${system} else v);
      outputsToRemove = [ "inputs" "outputs" "sourceInfo" ];
    in (removeSystemAttr (removeAttrs flake outputsToRemove)));
  };

  types = (
  let
    mkPathOption = { name, prefix }: lib.mkOptionType {
      inherit name;
      description = "An absolute path, prefixed with ${prefix}.";
      descriptionClass = "nonRestrictiveClause";

      check = (x:
        lib.isStringLike x &&
        lib.substring 0 1 x == prefix
      );
      merge = lib.mergeEqualOption;
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
  }) // lib.types;
}