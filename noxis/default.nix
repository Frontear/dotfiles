{
  ...
}: {
  home-manager.users."frontear" =
  {
    ...
  }: {
    imports = [
      ./home.nix
    ];
  };
}
