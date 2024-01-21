{ ... }: {
  # Enable unfree packages so I can use things like Microsoft Edge, VSCode, and other packages.
  nixpkgs.config.allowUnfree = true;

  # TODO: add overlay or something so that nix-shell -p OR nix shell nixpkgs# can work with
  # unfree packages w/o needing that env variable.
}
