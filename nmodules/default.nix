inputs: # TODO: abuse __functor and __functionArgs?
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./common
    ./system
    ./users
  ];

  config = {
    _module.args = { inherit inputs; };
  };
}