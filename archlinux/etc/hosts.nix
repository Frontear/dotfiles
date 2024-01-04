{
  lib,
  ...
}: {
  environment.etc."hosts".source = lib.mkForce ./hosts;
}
