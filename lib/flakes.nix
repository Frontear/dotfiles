{
  self,
  lib,
  ...
}:
let
  self' = {
    mkModules = (modulesPath: { ... } @ extraArgs: {
      imports = lib.filesystem.listFilesRecursive modulesPath
        |> lib.filter (lib.hasSuffix "module.nix")
        |> map (mod:
        let
          imported = import mod;
        in {
          # args = { config, lib, modulesPath, options, pkgs, ... }
          __functor = _: args: (imported (args // extraArgs)) // {
            _file = mod; # better error reporting in the module system
          };
          __functionArgs = lib.functionArgs imported;
        }
      );
    });

    mkNixOSConfigurations = (system: list: list
      |> map ({ hostName, modules, ... } @ extraArgs: {
        name = hostName;
        value = lib.nixosSystem {
          specialArgs = {
            #self = self'.stripSystem system self;
          } // (if extraArgs ? specialArgs then extraArgs.specialArgs else {});

          modules = [
            (self.nixosModules.default or {})
            {
              networking.hostName = hostName;
              nixpkgs.hostPlatform = system;
            }
          ] ++ modules;
        } // (removeAttrs extraArgs [ "hostName" "modules" "specialArgs" ]);
      })
      |> lib.listToAttrs
    );

    mkPackages = (pkgs: directory: builtins.readDir directory
      |> lib.mapAttrs (name: _:
        pkgs.callPackage "${directory}/${name}/nix/package.nix" {}
      )
    );

    stripSystem = (system: flake:
    let
      removeSystemAttr = lib.mapAttrs (_: v: if v ? ${system} then v.${system} else v);
      outputsToRemove = [ "inputs" "outputs" "sourceInfo" ];
    in (removeSystemAttr (removeAttrs flake outputsToRemove)));
  };
in
  self'
