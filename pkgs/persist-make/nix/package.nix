{
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "persist-make";
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

  meta = with lib; {
    description = "Make path(s) with identical perms to a reference path(s)";

    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ frontear ];
    platforms = platforms.linux;

    mainProgram = "persist-make";
  };
}
