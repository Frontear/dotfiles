{
  lib,
  runCommandLocal,
  writeShellScriptBin,

  nix,
}:
let
  nix-wrapped = writeShellScriptBin "nix" ''
    declare -a args
    
    if [ "$1" = "repl" ]; then
      # https://wiki.nixos.org/wiki/Flakes#Getting_Instant_System_Flakes_Repl
      args+=(repl --expr "builtins // { inherit (import <nixpkgs> {}) pkgs lib; }")
      shift 1
    fi

    # https://discourse.nixos.org/t/how-do-nix-legacy-commands-work-when-they-are-just-symbolic-links-to-nix/52797
    cmd=(
      "$(basename $0)"
      "''${args[@]}"
      "$@"
    )

    PATH="${nix}/bin:$PATH" exec "''${cmd[@]}"
  '';
in runCommandLocal "wrap-nix" {
  pname = lib.getName nix;
  version = lib.getVersion nix;

  outputs = nix.outputs;

  meta.mainProgram = "nix";
} ''
  install -Dm755 -t $out/bin ${lib.getExe nix-wrapped}

  ${lib.concatStringsSep "\n" (map (output: ''
    mkdir -p ${placeholder output}
    cp --update=none -rt ${placeholder output} ${nix.${output}}/*
  ''
  ) nix.outputs)}
''
