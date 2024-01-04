{
  ...
}: {
  imports = [
    ./boot
    ./etc
    ./root
  ];

  home-manager.users.frontear =
  {
    ...
  }: {
    imports = [
      ./home
    ];

    home.stateVersion = "24.05";
  };
}
