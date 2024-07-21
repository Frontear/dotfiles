inputs: # TODO: abuse __functor and __functionArgs?
{
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