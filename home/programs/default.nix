{ ... }: {
  # Link program configurations to the home folder.
  # TODO: setup an auto-reload for when generations are switched.
  xdg.configFile = {
    "ags".source = ./ags;
    "hypr".source = ./hypr;
  };
}
