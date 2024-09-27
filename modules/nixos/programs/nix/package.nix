{
  lib,
  symlinkJoin,
  writeShellScriptBin,

  nix,
}:
symlinkJoin {
  # For the nixos module to lookup the right version
  name = lib.getName nix;
  version = lib.getVersion nix;

  paths = [
    (writeShellScriptBin "nix" ''
      declare -a args
      
      if [ "$1" = "repl" ]; then
        # https://wiki.nixos.org/wiki/Flakes#Getting_Instant_System_Flakes_Repl
        args+=(repl --expr "builtins // { inherit (import <nixpkgs> {}) pkgs lib; }")
        shift 1
      fi

      # https://discourse.nixos.org/t/how-do-nix-legacy-commands-work-when-they-are-just-symbolic-links-to-nix/52797
      cmd=(
        "${nix}/bin/$(basename $0)"
        "''${args[@]}"
        "$@"
      )

      exec "''${cmd[@]}"
    '')
    nix
  ];

  meta.mainProgram = "nix";
}
