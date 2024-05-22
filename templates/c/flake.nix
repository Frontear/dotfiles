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
      packages = eachSystem (pkgs: {
        default = pkgs.callPackage ({ pkgs, stdenv }:
          stdenv.mkDerivation rec {
            pname = "app";
            version = "0.1";

            meta.mainProgram = pname;

            src = ./src;

            buildPhase = ''
              $CC $src/main.c -o ${meta.mainProgram}
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp ${meta.mainProgram} $out/bin
            '';
          }) { };
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [ gdb man-pages valgrind ];

          hardeningDisable = [ "all" ];
        };
      });
    };
}
