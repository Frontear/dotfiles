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
  };
}
