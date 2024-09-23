{
  lib,
  writeShellScriptBin,

  nix-package,
}:
writeShellScriptBin "nix" ''
  declare -a args

  if [ "$1" = "repl" ]; then
    args+=($1 --file "${./fast-repl.nix}")
    shift 1
  fi

  cmd=(
    ${lib.getExe nix-package}
    "''${args[@]}"
    "$@"
  )

  exec "''${cmd[@]}"
''
