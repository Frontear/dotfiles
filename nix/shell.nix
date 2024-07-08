let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
    sha256 = lock.nodes.nixpkgs.locked.narHash;
  };
in
{
  pkgs ? import nixpkgs {}
}:
pkgs.mkShell {
  packages = with pkgs; [
    nil

    (writeShellApplication {
      name = "rebuild";
      runtimeInputs = [
        nh
      ];
      text = ''
        MODE="$1"

        if [ -z "$MODE" ]; then
          MODE="test"
        fi
 
        if nh os "$MODE" --verbose . -- --show-trace --max-jobs auto --option eval-cache false "''${@:2}" && [ "$MODE" = "boot" ]; then
          reboot
        fi
      '';
    })

    (writeShellApplication {
      name = "gc";
      runtimeInputs = [
        nh
        nix
      ];
      text = ''
        # Clears `bootctl list` with the switch
        nh clean all && sudo nix-store --optimise && sudo /run/current-system/bin/switch-to-configuration switch
      '';
    })
  ];
}
