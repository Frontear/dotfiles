{ ... }: {
  # TODO: somehow write programs.hyprland.enable for both system configuration,
  # and configuration via home-manager, all in this singular file...
  xdg.configFile."hypr".source = ./config;
}
