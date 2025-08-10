{
  callPackage,
}:
let
  # TODO: move `./bin` to the `pkgs` directory at root.
  screenshot = callPackage ./bin/screenshot/package.nix {};
in {
  sway = callPackage ./sway {
    inherit screenshot;
  };


  dunst = callPackage ./dunst {};

  foot = callPackage ./foot {};

  rofi = callPackage ./rofi {};

  swayidle = callPackage ./swayidle {};

  swayosd = callPackage ./swayosd {};

  waybar = callPackage ./waybar {};
}
