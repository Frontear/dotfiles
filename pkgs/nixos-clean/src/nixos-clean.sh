#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH="@path@:$PATH"

showUsage() {
  echo "Usage: $(basename $0) [OPTION]..."
  echo "Clean up old NixOS and home-manager generations when applicable."
  echo ""
  echo "  -d, --dry-run     show what would be done without doing it"
  echo "  -v, --verbose     increase verbosity of diagnostic messages"
  echo "  -h, --help        display this help and exit"
  exit 1
}

if [ "$UID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

origArgs=("$@")
systemProfiles=/nix/var/nix/profiles
dryRun=
verbose=
cleanStore=

log() {
  if [ -n "$verbose" ]; then
    echo "[nixos-clean] $@" >&2
  fi
}

run() {
  if [ -n "$dryRun" ]; then
    echo "$@"
  elif [ -n "$verbose" ]; then
    $@
  else
    local discard=$($@ 2>&1)
  fi
}

while [ "$#" -gt 0 ]; do
  i="$1"; shift 1
  case "$i" in
    --help|-h)
      showUsage
      ;;
    --dry-run|-d)
      dryRun=1
      ;;
    --verbose|-v)
      verbose=1
      ;;
    *)
      log "unknown option '$i'"
      exit 1
      ;;
  esac
done

cleanNixOS() {
  log "cleaning up nixos generations..."

  local latest="$(readlink -f $systemProfiles/system)"
  for p in $systemProfiles/system*; do
    if [ "$(readlink -f $p)" != "$latest" ]; then
      log "going to delete $p"
      run rm -f "$p"
    fi
  done

  log "regenerating boot entries"
  run /run/current-system/bin/switch-to-configuration boot
}

cleanNix() {
  log "cleaning up the /nix/store"

  run nix-collect-garbage -d
}

if [ -f /etc/NIXOS ]; then
  cleanNixOS
  cleanStore=1
fi

if [ -n "$cleanStore" ]; then
  cleanNix
fi