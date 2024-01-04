{
  ...
}: {
  home-manager.users.root =
  {
    ...
  }: {
    home.file.".bashrc".source = ./.bashrc;

    home.stateVersion = "24.05";
  };
}
