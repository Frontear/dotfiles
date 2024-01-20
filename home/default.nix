{ ... }: {
  imports = [
    ./programs
    ./home.nix
  ];

  # Recursively link up the shell binaries into ~/.local/bin
  # TODO: is it a better idea to use Nix to generate the shell scripts?
  home.file.".local/bin" = {
    recursive = true;
    source = ./scripts;
  };
}
