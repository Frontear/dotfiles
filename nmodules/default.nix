inputs: # TODO: abuse __functor and __functionArgs
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (import ./system inputs)
  ];

  config = {};
}