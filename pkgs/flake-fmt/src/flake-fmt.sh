#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH="@path@:$PATH"

paths=("$@")

# empty input = `nix fmt` called with no args
# therefore, target path is current directory
#
# TODO: find flake root and start from there?
if [ "${#paths[@]}" -eq 0 ]; then
  paths=("$PWD")
fi

formatFile() {
  local file="$1"

  deadnix -LWqeh "$file"
  # TODO: implement an actual formatting step
}

for path in "${paths[@]}"; do
  if [ -d "$path" ]; then
    for entry in $(find "$path" -name "*.nix" -print); do
      formatFile "$entry"
    done
  elif [ -f "$path" ]; then
    formatFile "$path"
  else
    echo "[flake-fmt/ERR]: Unknown file type: '$path'"
    exit 1
  fi
done