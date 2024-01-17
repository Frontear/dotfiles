{
  ...
}: {
  imports = [
    ./boot.nix
    ./etc.nix
    ./root.nix
  ];

  home-manager.users."frontear" =
  {
    ...
  }: {
    imports = [
      ./home.nix
    ];
  };
}
