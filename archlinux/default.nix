{
  ...
}: {
  imports = [
    ./etc
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
