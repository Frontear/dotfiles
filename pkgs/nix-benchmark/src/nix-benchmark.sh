#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH="@path@:$PATH"

showUsage() {
  echo "Usage: $(basename $0) [OPTION]..."
  echo "Benchmark a Nix derivation using hyperfine. Executes through multiple"
  echo "Nix distributions and outputs final results for comparison."
  echo ""
  echo "Mandatory arguments:"
  echo "  -f, --flake [FLAKE_REF]     the output derivation to benchmark"
  echo ""
  echo "Optional arguments:"
  echo "  -h, --help        display this help and exit"
  exit 1
}

origArgs=("$@")
nixBins=(@nixBins@)
# We use both `pipe-operator` and `pipe-operators` because Lix decided to be
# quirky and remove the 's' from the name, whilst every other Nix version still
# uses 'operators'. Extremly irritating change on Lix's end.
nixEvalArgs="eval --option eval-cache false --option extra-experimental-features 'pipe-operator pipe-operators' --raw"
flakeRef=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --flake|-f)
      flakeRef="$2"; shift 1
      ;;
    --help|-h)
      showUsage
      ;;
    *)
      echo "unknown option '$1'"
      exit 1
      ;;
  esac

  shift 1
done

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

if [ -z "$flakeRef" ]; then
  echo "A flake output must be specified."
  exit 1
fi

benchmarkNixEval() {
  local nixBinary="$1"

  local name="$($nixBinary --version 2> /dev/null | head -n1)"
  local cmd="$nixBinary $nixEvalArgs '$flakeRef.drvPath'"

  hyperfine --warmup 5 --runs 20 --command-name "$name" "$cmd"
}

for bin in "${nixBins[@]}"; do
  benchmarkNixEval "$bin"
done
