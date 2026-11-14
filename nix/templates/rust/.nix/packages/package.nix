{
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "app";
  version = "0.1.0";

  src = with lib.fileset; toSource {
    root = ../../app;
    fileset = unions [
      ../../app/src
      ../../app/Cargo.lock
      ../../app/Cargo.toml
    ];
  };

  cargoLock.lockFile = ../../app/Cargo.lock;

  meta = with lib; {
  };
})