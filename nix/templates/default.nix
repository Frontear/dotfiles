{
  flake = {
    templates = {
      default = {
        path = ./parts;
        description = ''
          A minimal flake using flake-parts.
        '';
      };

      python = {
        path = ./python;
        description = ''
          An opinionated Python template.
        '';
      };

      rust = {
        path = ./rust;
        description = ''
          An opinionated Rust template.
        '';

        welcomeText = ''
          > **Warning** \
          > Make sure to re-generate the `Cargo.lock` file!
        '';
      };
    };
  };
}