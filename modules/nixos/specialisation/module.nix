{
  lib,
  ...
}:
let
  specialisationSubmodule = { name, ... }: {
    config.configuration = {
      # Creates a special file at `/etc/specialistion` that contains the
      # current name of the specialisation that is booted. This can be
      # used to determine the behaviour of `switch-to-configuration`.
      environment.etc."specialisation".text = name;
    };
  };
in {
  options = {
    specialisation = lib.mkOption {
      type = with lib.types; attrsOf (submodule specialisationSubmodule);
    };
  };
}