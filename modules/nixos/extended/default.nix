{
  config,
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

  # TODO: best place?
  config = lib.mkIf config.nixpkgs.config.allowUnfree {
    hardware.enableAllFirmware = true;

    # Enable SysRq
    boot.kernel.sysctl."kernel.sysrq" = 1;
  };
}
