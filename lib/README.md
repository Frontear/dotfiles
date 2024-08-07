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