#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

currentDir="$(dirname "$(readlink -f "$0")")"

# safety to prevent issues from changing the extensions.nix file
if ! nix run "github:Frontear/code2nix" -- -f "$currentDir/extensions.nix" -o "$currentDir/extensions.nix.new"; then
  echo "Extension update failed"
  exit 1
fi

# atomically replace
mv "$currentDir/extensions.nix"{.new,}

# pretty-format (TODO: make this part of code2nix?)
nix run "nixpkgs#nixfmt" -- "$currentDir/extensions.nix"