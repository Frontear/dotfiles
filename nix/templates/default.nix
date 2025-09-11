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
        description = ''
          An optionated Rust template.
        '';

        welcomeText = ''
          > **Warning** \
          > Make sure to re-generate the `Cargo.lock` file!
        '';
      };
    };
  };
}