{
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sl-darken";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../.;
    fileset = unions [
      ../src
      ../Cargo.lock
      ../Cargo.toml
    ];
  };

  cargoLock.lockFile = ../Cargo.lock;

  passthru = {
    libPath = "lib/libsl_darken.so"; # convenience
  };

  meta = with lib; {
    description = "Darken the background image for Swaylock Effects";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;
  };
})