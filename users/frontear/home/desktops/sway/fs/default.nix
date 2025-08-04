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


  foot = callPackage ./foot {};

  swayidle = callPackage ./swayidle {};

  waybar = callPackage ./waybar {};
}
