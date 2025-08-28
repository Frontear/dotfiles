{
  inputs = {
    self.url = "git+file:../..";

    flake-parts.follows = "self/flake-parts";
    nixpkgs.follows = "self/nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      ./nix
    ];

    systems = inputs.nixpkgs.lib.systems.flakeExposed;
  };
}
