{
  ...
}:
{
  users.extraUsers = {
    # TODO: all options
    frontear = {
      name = "frontear";
      home = "/home/frontear";

      isNormalUser = true;
    };
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;

    users.frontear = ./frontear;
  };
}