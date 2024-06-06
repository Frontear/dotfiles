{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
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
              vm)
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild build-vm --flake .#minimal --use-remote-sudo --verbose --option eval-cache false --show-trace
                ./result/bin/run-minimal-vm
                rm -r ./result ./minimal.qcow2
                exit 0
                ;;
              *)
                ${pkgs.nixos-rebuild}/bin/nixos-rebuild test --flake . --use-remote-sudo --verbose --option eval-cache false --show-trace
            esac

            if [ $? -eq 0 -a $HOSTNAME != "nixos" ]; then
              hyprctl reload
              pkill waybar
              unset GDK_BACKEND && waybar > /dev/null 2>&1 &
              disown
            fi

            ${pkgs.coreutils}/bin/kill -INT $$ # simulates ^C
          '')
        ];
      };
    };
    flake = {
      nixosConfigurations = {
        "LAPTOP-3DT4F02" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit (self) outputs;
          };

          modules = [
            ./hosts/laptop
          ];
        };

        "nixos" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit (self) outputs;
          };

          modules = [
            ./hosts/desktop-wsl
          ];
        };

        "minimal" = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/minimal
          ];
        };
      };

      nixosModules = import ./modules;
      programs = import ./programs;
    };
  };
}
