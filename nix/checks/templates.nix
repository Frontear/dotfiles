{
  inputs,
  self,
  lib,
  ...
}:
let
  mkTemplateCheck = pkgs: template: let
    system = pkgs.stdenv.hostPlatform.system;

    inputs' = {
      inherit (inputs)
        flake-parts
        nixpkgs
        ;
    };

    outputs = (import (template.path + /flake.nix)).outputs (inputs' // {
      # I don't even understand why flakes are like this, but this junk is
      # actually part of the "inputs" parameter of the outputs function,
      # and is needed for evaluation.
      self = outputs // {
        inputs = inputs';
      };
    });
  in pkgs.linkFarm "template-${baseNameOf template.path}" (
    [
      outputs.devShells.${system}.default
      outputs.packages.${system}.default
    ]
    |> lib.map (x: {
      name = lib.getName x;
      path = x;
    })
  );
in {
  perSystem = { pkgs, ... }: {
    checks = {
      templates = pkgs.linkFarm "all-templates" (
        self.templates
        # The default template does not provide a buildable package
        # nor a useful devShell. It's meant to be extended, so exclude
        # it here, since there's nothing useful to test.
        |> (x: lib.removeAttrs x [ "default" ])
        |> lib.mapAttrsToList (name: value: {
          inherit name;
          path = mkTemplateCheck pkgs value;
        })
      );
    };
  };
}