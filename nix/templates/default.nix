{
  flake = {
    templates = {
      default = {
        path = ./parts;
        description = ''
          A minimal flake using flake-parts.
        '';
      };

      rust = {
        path = ./rust;
        welcomeText = ''
          > **Warning** \
          > Make sure to re-generate the `Cargo.lock` file!
        '';
      };
    };
  };
}
