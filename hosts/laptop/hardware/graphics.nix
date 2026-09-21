{
  ...
}:
{
  config = {
    hardware.intelgpu = {
      driver = "xe";
    };

    boot.extraModprobeConfig = ''
      options i915  force_probe=!9a49
      options xe    force_probe=9a49
    '';
  };
}