{
  config,
  ...
}: {
  programs.direnv = {
    enable = true;
    config = {
      whitelist = {
        prefix = [ "${config.home.homeDirectory}/Documents/projects" ];
      };
    };

    # Locks direnv changes into the store, very helpful when coupled
    # with a shell.nix for persistent devshells even across store cleanups.
    nix-direnv.enable = true;
  };
}
