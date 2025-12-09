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
  local nixEvalArgs="eval --raw --option 'eval-cache' 'false' --option 'extra-experimental-features'"

  local name="$($nixBinary --version 2> /dev/null | head -n1)"

  # Both Nix and Lix support the pipe (`|>`) operator through an optional
  # experimental feature toggle. However, they both use different names for
  # the feature. Lix uses 'pipe-operator', whilst Nix uses 'pipe-operators'.
  #
  # Lix's reasoning is that their implementation of the operator differs from
  # official Nix, and as a result should be disambiguated. In practice I have
  # not actually seen much of a difference, but I'll take their word for it.
  #
  # In order to respect this difference, I append to the experimental feature
  # depending on which version of Nix is being used for benchmarking.
  if [[ "$name" == "nix (Lix, like Nix)"* ]]; then
    nixEvalArgs="$nixEvalArgs 'pipe-operator'"
  else
    nixEvalArgs="$nixEvalArgs 'pipe-operators'"
  fi

  local cmd="$nixBinary $nixEvalArgs '$flakeRef.drvPath'"

  hyperfine --warmup 5 --runs 20 --command-name "$name" "$cmd"
}

for bin in "${nixBins[@]}"; do
  benchmarkNixEval "$bin"
done