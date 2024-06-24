{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Maybe flake-parts would be good for this :p
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      # To import a flake module
      # 1. Add foo to inputs
      # 2. Add foo as a parameter to the outputs function
      # 3. Add here: foo.flakeModule
    ];
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    perSystem = { config, self', inputs', pkgs, system, ... }: {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          nixpkgs-fmt

          (writeShellScriptBin "nixos-rebuild" ''
            case $1 in
              boot)
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake . --use-remote-sudo --verbose --option eval-cache false --show-trace
                reboot
                ;;
              switch)
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake . --use-remote-sudo --verbose --option eval-cache false --show-trace
                ;;
              *)
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild test --flake . --use-remote-sudo --verbose --option eval-cache false --show-trace
            esac

            kill -INT $$ # simulates ^C
          '')

          (writeShellScriptBin "nix-collect-garbage" ''
            if [ "$EUID" -ne 0 ]; then
              echo "Please run this script with root privileges"
              exit
            fi

            ${pkgs.nix}/bin/nix-collect-garbage -d && nix-store --optimise && /run/current-system/bin/switch-to-configuration switch
          '')
        ];
      };
    };
    flake = {
      nixosConfigurations = {
        "LAPTOP-3DT4F02" = nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default

            (import ./hosts/common { inherit (inputs) home-manager; })
            (import ./hosts/laptop { inherit (inputs) nixos-hardware; })
          ];
        };

        "nixos" = nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default

            (import ./hosts/common { inherit (inputs) home-manager; })
            (import ./hosts/desktop-wsl { inherit (inputs) nixos-wsl; })
          ];
        };
      };

      nixosModules.default = import ./modules { inherit (inputs) impermanence nixvim nix-vscode-extensions; };
    };
  };
}
