{
  lib,
  ...
}:
{
  perSystem = { self', pkgs, ... }: {
    devShells = self'.packages
      |> lib.mapAttrs (_: value: pkgs.mkShell {
        inputsFrom = [
          value
        ];
      });
  };
}