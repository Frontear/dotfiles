{
  symlinkJoin,

  writeTextDir,
  sway,

  # see: https://github.com/NixOS/nixpkgs/blob/dc9637876d0dcc8c9e5e22986b857632effeb727/nixos/modules/programs/wayland/sway.nix#L26-L29
  extraSessionCommands ? "",
  extraOptions ? [],
  withBaseWrapper ? true,
  withGtkWrapper ? false,
  enableXWayland ? true,
  isNixOS ? false,
}:
symlinkJoin {
  name = "sway-no-desktop-entry";

  paths = [
    # Sway provides a default `sway.desktop` which is linked by NixOS to
    # allow display managers to recognize Sway as a login target. This conflicts
    # with our desire to use UWSM exclusively, as it shows both, and it can
    # be confusing/annoying to switch between them. In an effort to prevent
    # that from being an issue, we completely wipe the `sway.desktop` file,
    # which will prevent it from being registered as valid (at least on tuigreet).
    (writeTextDir "/share/wayland-sessions/sway.desktop" "")
    (sway.override {
      inherit
        extraSessionCommands
        extraOptions
        withBaseWrapper
        withGtkWrapper
        enableXWayland
        isNixOS
        ;
    })
  ];

  passthru = {
    inherit (sway) providedSessions;
  };
}
