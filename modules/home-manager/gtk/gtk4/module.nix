{
  config,
  ...
}:
{
  config = {
    # Preserve the legacy behaviour of home-manager < 26.05. This requires that
    # the theme declared on `config.gtk.theme` is compatible with GTK4.
    gtk.gtk4.theme = config.gtk.theme;
  };
}