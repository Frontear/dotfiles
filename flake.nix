{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      #inputs.nixpkgs.follows = "nixpkgs";
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

    stevenblack = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };

    waybar = {
      url = "github:Alexays/waybar";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... } @ inputs:
    let
      inherit (self) outputs;

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
          })
        );
    in {
      nixosModules = import ./modules/nixos;

      programs = import ./programs;

      nixosConfigurations = {
        "LAPTOP-3DT4F02" = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./hosts/laptop
          ];
        };
        "nixos" = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./hosts/desktop-wsl
          ];
        };
      };

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            (writeShellScriptBin "nixos-rebuild" ''
              case $1 in
                boot)
                  ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake ${./.} --use-remote-sudo --verbose --option eval-cache false
                  reboot
                  ;;
                *)
                  ${pkgs.nixos-rebuild}/bin/nixos-rebuild test --flake ${./.} --use-remote-sudo --verbose --option eval-cache false
              esac
            '')
          ];
        };
      });
    };
}
