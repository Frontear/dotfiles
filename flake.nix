{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    DankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        dms-cli.follows = "dms-cli";
      };
    };

    dms-cli = {
      url = "path:./nix/inputs/dms-cli";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter = {
      url = "github:nix-community/nixos-facter";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules = {
      url = "github:nix-community/nixos-facter-modules";
    };

    quickshell = {
      url = "github:quickshell-mirror/quickshell";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      ./nix
    ];

    systems = inputs.nixpkgs.lib.systems.flakeExposed;
  };
}