{
  lib,
  ...
}:
{
  options.specialisation = lib.mkOption {
    type = with lib.types; attrsOf (submodule (
    {
      name,
      ...
    }:
    {
      # Helps rebuild discern specialisation for test/switch
      config.configuration = {
        environment.etc."specialisation".text = "${name}";
      };
    }));
  };
}
