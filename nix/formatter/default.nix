{
  ...
}:
{
  perSystem = { self', ... }: {
    formatter = self'.packages.flake-fmt;
  };
}