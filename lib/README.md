# Lib Extension
Documentation for my lib extensions, because I want to keep the `default.nix` as free of comments as possible.

## flake.mkModules
Takes one argument, a path to a directory tree of modules.

Returns a module expression that imports all modules found within the directory tree. The assumption is that modules are defined in `default.nix`, and any other files are ignored as they are assumed to be linked by the aforementioned entrypoint.

Usage:
```nix
outputs = { self, nixpkgs, ... }:
let
  lib = nixpkgs.lib.extend (_: prev: import ./. {
    inherit self;
    lib = prev;
  });
in {
  nixosModules.default = lib.flake.mkModules ./modules;
};
```

## flake.mkNixOSConfigurations
Takes two arguments, a defined system and a list of valid attributes that can be passed to `lib.evalModules`, with an added `hostName` attribute.

Returns an attribute set that maps the given `hostName` and other attributes to the `nixosConfigurations` flake schema. This function only expects a `hostName` and `modules` attributes in the list. This function will also implicitly add `self.nixosModules.default` to the module list, as well as set `networking.hostName` and `nixpkgs.hostPlatform`.

Usage:
```nix
outputs = { self, nixpkgs, ... }:
let
  lib = nixpkgs.lib.extend (_: prev: import ./. {
    inherit self;
    lib = prev;
  });
in {
  nixosConfigurations = lib.flake.mkNixOSConfigurations "x86_64-linux" [
    {
      hostName = "nixos";
      modules = [
        ./configuration.nix
      ];
    }
  ];
};
```

## flake.mkSelf'
Takes one argument, a reference to the `system` attribute on which to transform `self`.

Returns a modified version of `self` (colloquially referred to as `self'`), that transforms system-dependent outputs into system-independent outputs based on the desired system. Furthermore, it transforms inputs in the same way, and removes from repeated attributes from both `self` and `inputs` that are accessible in other ways (`outputs` is removed as all values in outputs are mapped to the root attrset, `sourceInfo` for the same reason). For `self.inputs` specifically, it removes deeper `inputs` as well, as those are unlikely to be used and can be discarded safely.

Usage:
```nix
outputs = { self, nixpkgs, ... }:
let
  lib = nixpkgs.lib.extend (_: prev: import ./. {
    inherit self;
    lib = prev;
  });

  self' = lib.flake.mkSelf' "x86_64-linux";
in {
  nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
    modules = [
      {
        environment.systemPackages = [
          self'.packages.hello
          self'.inputs.foo.packages.bar
          self'.inputs.nixpkgs.legacyPackages.steam
        ];
      }
    ];
  };
};
```

## types.systemPath
A `type` definition for any arbitrary path that begins with `/`. Intended to be used in a `mkOption` declaration.

Usage:
```nix
{ lib, ... }:
let
  inherit (lib) mkOption types;
in {
  options.foo = mkOption {
    type = types.systemPath;
  };
}
```

## types.userPath
A `type` definition for any arbitrary path that begins with `~`. This should be resolved to an absolute path within the module. Intended to be used in a `mkOption` declaration.

Usage:
```nix
{ lib, ... }:
let
  inherit (lib) mkOption types;
in {
  options.bar = mkOption {
    type = types.userPath;
    apply = x: lib.replaceStrings [ "~" ] [ "/some/absolute/path" ] x;
  };
}
```