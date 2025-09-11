{
  lib,
  rustPlatform,

  pkg-config,

  at-spi2-atk,
  cairo,
  gdk-pixbuf,
  glib,
  gtk3,
  pango,
}:
rustPlatform.buildRustPackage {
  pname = "waybar-icon";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../.;
    fileset = unions [
      ../src
      ../Cargo.lock
      ../Cargo.toml
    ];
  };

  outputs = [
    "out"
    "lib" # Convenience output
  ];

  cargoLock.lockFile = ../Cargo.lock;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    at-spi2-atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    pango
  ];

  postInstall = ''
    install -Dm755 $out/lib/libwaybar_icon.so $lib
  '';

  meta = with lib; {
    description = "Waybar module to display a GTK icon";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;
  };
}