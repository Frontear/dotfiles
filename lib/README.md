# Lib Extension
Documentation for my lib extensions, because I want to keep the `default.nix` as free of comments as possible.

## flake.mkModules
Takes two arguments, a path to your NixOS modules, and extra arguments you wish to append to the module's function call.

Returns an expression valid for the purposes of `lib.evalModules` that imports all `default.nix` files found within the provided directory tree, joined with the extra arguments from the flake using some hacky `__functor` and `__functionArgs` magic.

The main benefit of providing this is being able to pass arbitrary arguments to the modules independent of the hosts `specialArgs` or `_module.args` value. Furthermore, no argument passed through this way leaks into the main module context, ensuring complete isolation.

> [!WARNING]
> Please note that this function will ONLY import `default.nix` files.
> All other files will be ignored, meaning it is up to you, as the
> module author to connect them together.
>
> This function will infrec if the provided modules path is `./.` and
> a `default.nix` exists at `./.`. This is due to an internal design
> detail that recursively processes the file tree. If `./.` is given,
> it will continue to recurse on itself and re-trigger this module.
> As such, execute this function call from outside the modules tree.
> A good place is your `flake.nix`, as provided in the example below.

Usage:
```nix
outputs = { self, nixpkgs, ... } @ inputs:
let
  lib = nixpkgs.lib.extend (_: prev: import ./. {
    inherit self;
    lib = prev;
  });
in {
  nixosModules.default = lib.flake.mkModules ./modules {
    inherit inputs; # all modules can access inputs in their args.
  };
};
```

## flake.mkNixOSConfigurations
Takes two arguments, a valid system, and a list of attrsets that are directly passed into `lib.nixosSystem`. Attributes `hostName` and `modules` must exist for each attrset in the list.

Returns an attribute set following the schema of `nixosConfigurations`, where `hostName` denotes the attribute name, and all other outputs (including `modules`) are passed into `lib.nixosSystem`, which then becomes the value.

The main benefit of this function is simplifying and reducing repetition in system declarations. Since the hostname and system attributes are provided within the flake itself through this function, they can be mapped to `networking.hostName` and `nixpkgs.hostPlatform` respectively, further de-duplicating configuration. This function will also implicitly add `self.nixosModules.default` unless no such attribute exists.

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

## flake.stripSystem
Takes two arguments, a valid system, and a flake-schema attrset which is transformed to remove all system-specific attrs and directly map them to their respective attributes. Attributes like `packages.x86_64-linux.default` are mapped to `packages.default`.

Returns a valid flake-schema attrset which strips all system attribute names, and directly maps their values to the parent attribute, reducing duplication and easing the usage of flake outputs in given scenarios.

The main benefit of this function is to reduce bothersome system attribute handling. In many cases the system can be guaranteed ahead-of-time, and in these cases needing to type things like `${pkgs.system}` or `${system}` is just repetitive. This function will completely strip off all system-specific names to make the entire output _seem_ system agnostic.

> [!WARNING]
> This will strip the flake attrset of some key attributes, specifically `inputs`,
> `outputs`, and `sourceInfo`. outputs and sourceInfo are removed because their
> attribute values are part of the root attrset, but inputs is removed simply
> to avoid going deep into the inputs and mis-handling them. This is a very
> opinionated decision, and I instead encourage passing inputs directly via
> `input-name = lib.flake.stripSystem <SYSTEM> inputs.input-name`.

Usage:
```nix
outputs = { self, nixpkgs, foo, ... }:
let
  lib = nixpkgs.lib.extend (_: prev: import ./. {
    inherit self;
    lib = prev;
  });

  self' = lib.flake.stripSystem "x86_64-linux" self;
  nixpkgs' = lib.flake.stripSystem "x86_64-linux" nixpkgs;
  foo' = lib.flake.stripSystem "x86_64-linux" foo;
in {
  nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
    modules = [
      {
        environment.systemPackages = [
          self'.packages.hello
          foo.packages.bar
          nixpkgs'.legacyPackages.steam
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