{
  mkShell,
  nh,
  nil,
  nix,
  writeShellApplication,
}:
mkShell {
  packages = [
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
