{
  self,
  lib,
  ...
}:
let
  # TODO: this doesn't clearly communicate the intent of how modules should be
  # structured in the shared directory. From just this snippet, it appears that
  # modules should be in the form `<module-dir>/{nixos.nix,home-manager.nix}`,
  # but I'm doing `<module-dir>/{config,options}/{nixos.nix,home-manager.nix}`.
  #
  # There should be a strict requirement here, I'm not sure whether I want to
  # enforce the `config/options` directory or `nixos/home-manager` as the first
  # directory. I can see valid use-cases for both..
  sharedNixOSEntrypoints = [ "nixos.nix" "nixos" ];
  sharedHomeManagerEntrypoints = [ "home-manager.nix" "home-manager" ];

  levelEntrypoints = [
    "module.nix"

    "config.nix" "config"
    "options.nix" "options"
  ];

  # Accept any/all of the entrypoints. This is slightly better than using
  # `lib.filesystem.listFilesRecursive` because the recursion can be forcibly
  # stopped early when valid imports are found, saving on precious I/O time
  # that could be used elsewhere.
  #
  # NOTE: There is no error or duplication checking. A module can multiple of
  # these things, which can possibly cause duplicate definitions.
  listFilesRecursive = (modulesPath: moduleEntrypoints:
  let
    entries = builtins.readDir modulesPath;
    importOptional = file: lib.optional (entries ? "${file}") (modulesPath + "/${file}");

    modules =
      map importOptional moduleEntrypoints
      |> lib.flatten;
  in
    # Does not recurse when valid import files are found.
    modules ++ lib.optionals (modules == []) (entries
      |> lib.filterAttrs (_: value: value == "directory")
      |> lib.mapAttrsToList (name: _: listFilesRecursive (modulesPath + "/${name}") moduleEntrypoints)
      |> lib.flatten)
  );

  # Wrap in an extremely hacky functor to extend arguments given into the
  # module without using the extra upper function of upstream's implementation
  # of  `lib.importApply`.
  importApply = (_file: extraArgs:
  let
    imported = import _file;
  in {
    # args = { config, lib, modulesPath, options, pkgs, ... }
    __functor = _: args: (imported (args // extraArgs)) // {
      inherit _file; # better error reporting in the module system
    };

    __functionArgs = lib.functionArgs imported;
  });

  self' = {
    mkModules = (directory: { ... } @ extraArgs:
    let
      levelNixOS = listFilesRecursive (directory + "/nixos") levelEntrypoints;
      levelHomeManager = listFilesRecursive (directory + "/home-manager") levelEntrypoints;

      # TODO: performance penalties for iterating this same directory twice.
      # Should it be merged into one operation, and separated later?
      sharedNixOS = listFilesRecursive (directory + "/shared") sharedNixOSEntrypoints;
      sharedHomeManager = listFilesRecursive (directory + "/shared") sharedHomeManagerEntrypoints;
    in {
      imports = map (file:
        importApply file extraArgs
      ) (levelNixOS ++ sharedNixOS);

      config.home-manager.sharedModules = map (file:
        importApply file extraArgs
      ) (levelHomeManager ++ sharedHomeManager);
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
        pkgs.callPackage (directory + "/${name}/nix/package.nix") {}
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