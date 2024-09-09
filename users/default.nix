{
  ...
}:
{
  imports = [
    ./frontear
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
  };
}