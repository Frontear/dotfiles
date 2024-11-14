#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

origArgs=("$@")
newArgs=()

for i in "${!origArgs[@]}"; do
  newArgs+=("${origArgs[$i]}")

  if [ $i -eq 0 ]; then
    case "${origArgs[0]}" in
      repl)
        newArgs+=("--expr" "builtins // { inherit (import <nixpkgs> { config.allowUnfree = true; }) pkgs lib; }")
        ;;
    esac
  fi
done

# The official Nix binary resolves nix-legacy binary calls through
# disambiguating $0. This means we must set it directly here in the
# exec call in order to help it out.
exec -a "$0" "@nix@" "${newArgs[@]}"
