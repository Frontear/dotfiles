{
  lib,
  ...
}:
{
  options = {
    my.programs.powertop = {
      enable = lib.mkDefaultEnableOption "powertop";
    };
  };
}
