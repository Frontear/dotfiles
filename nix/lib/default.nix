{
  self,
  inputs,
  ...
}:
{
  flake.lib = inputs.nixpkgs.lib.extend (final: prev:
    import ../../lib { inherit final prev self; }
  );
}
