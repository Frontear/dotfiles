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
    ./users
  ];

  config = {
    _module.args = { inherit inputs; };
  };
}