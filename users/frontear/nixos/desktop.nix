{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.desktops.sway.enable {
    users.users."frontear".extraGroups = [
      "video"
      config.programs.ydotool.group
    ];

    hardware.acpilight.enable = true;
    programs.ydotool.enable = true;
  };
}
