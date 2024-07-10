inputs: # TODO: abuse __functor and __functionArgs?
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./system
  ];

  config = {
    _module.args = { inherit inputs; };
  };
}