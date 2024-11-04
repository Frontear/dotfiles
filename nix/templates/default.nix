{
  flake = {
    templates.default = {
      path = ./parts;
      description = ''
        A minimal flake using flake-parts;
      '';
    };
  };
}
