{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, ... }@inputs:
    let
      # https://ayats.org/blog/no-flake-utils
      eachSystem = function:
        inputs.nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-linux"
          "aarch64-darwin"
        ] (system:
          function (import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          }));
    in {
      packages = eachSystem (pkgs:
        {
          # default = pkgs.callPackage {};
          # <name> = pkgs.callPackage {};
        });

      devShells = eachSystem (pkgs:
        {
          # default = pkgs.mkShell {};
          # <name> = pkgs.mkShell {};
        });
    };
}
