# Lib Extension
Documentation for my lib extensions, because I want to keep the `default.nix` as free of comments as possible.

## importsRecursive
Takes two arguments, a path and a predicate function.

Returns a list of `.nix` files from the specified directory and recursively down its tree that qualify with the defined predicate.

This function is intended only to be used with `imports` within the context of the module system. It is also largely intended that the path be itself, although it expects other path. Given the previous assumption, it also avoids returning the calling file (assumed `default.nix`) to avoid an infrec.

Usage:
```nix
{ lib, ... }: {
  imports = lib.importsRecursive ./. (x: x == "default.nix");
}
```

## flake.mkHostConfigurations
Takes two arguments, a system and a list of valid `nixosSystem` attributes + a hostName attribute.

Returns an attribute set that exposes NixOS Configurations in the form `${hostName} = nixosSystem { ... }`.

This function attempts to expose the `nixosConfigurations` flake output in a more deterministic manner, handling the system and hostName at the flake level to avoid inconsistency within the configuration. It also exposes `self` in `specialArgs` with system-specific outputs re-mapped to not require them. This means things like `self.packages.x86_64-linux.default` is accessed via `self.packages.default`.

Usage:
```nix
outputs = { self, nixpkgs, ... }:
let
  lib = nixpkgs.lib.extend (_: prev: import ./. {
    inherit self;
    lib = prev;
  });
in {
  nixosConfigurations = lib.flake.mkHostConfigurations "x86_64-linux" [{
    hostName = "nixos";
    modules = [
      ./configuration.nix
    ];
  }];
}
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