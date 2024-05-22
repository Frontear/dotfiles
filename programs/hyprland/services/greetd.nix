{ config, pkgs, ... }: {
  # System
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command =
            "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${config.programs.hyprland.package}/bin/Hyprland --time --remember --remember-session --asterisks";
        };
      };
    };
  };
}
