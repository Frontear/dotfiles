#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH="@path@:$PATH"

showUsage() {
  echo "Usage: $(basename $0)"
  echo "Configure NixOS to boot the current generation instead of the latest."
  echo "This script will have no effect unless run from an older generation."
  echo ""
  echo "  -d, --dry-run   show what would be done without doing it"
  echo "  -q, --quiet     suppress all normal output"
  echo "  -v, --verbose   increase verbosity level of diagnostic messages"
  echo "  -h, --help      display this help and exit"
  exit 1
}

if [ "$UID" -eq 0 ]; then
  echo "Do not run this script as root."
  exit 1
fi

origArgs=("$@")
profilesPath=/nix/var/nix/profiles
systemProfile=/nix/var/nix/profiles/system
currentGeneration=/run/booted-system
dryRun=
verbose=1

run() {
  if [ -n "$dryRun" ]; then
    echo "$ $@"
  elif [ $verbose -ge 2 ]; then
    $@
  else
    local discard=$($@ 2>&1)
  fi
}

log() {
  if [ $verbose -ge 2 ]; then
    echo "[nixos-clean/LOG]: $@"
  fi
}

info() {
  if [ $verbose -ge 1 ]; then
    echo "[nixos-clean/INFO]: $@"
  fi
}

warn() {
  echo "[nixos-clean/WARN]: $@"
}

err() {
  echo "[nixos-clean/ERROR]: $@"
  exit 1
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
    --quiet|-q)
      verbose=$((verbose - 1))
      ;;
    --verbose|-v)
      verbose=$((verbose + 1))
      ;;
    *)
      log "unknown option '$i'"
      exit 1
  esac
done

_extractGenNum() {
  local path="$1"

  local _strip_profile_path="${path//$profilesPath/}"
  local _number=$(echo "$_strip_profile_path" | cut -d '-' -f 2)

  echo "$_number"
}

rollbackGeneration() {
  local current_path="$(readlink -f "$currentGeneration")"
  log "resolved current generation path to: '$current_path'"

  # Normal detection will fail when booted into a specialisation.
  # This is because the system profiles GC root the main system closure,
  # which indirectly roots the specialisation closure, since the main closure
  # contains the specialisation at `/nix/store/<closure>/specialisations`.
  #
  # To fix detection, we need to find the main system closure. This only makes
  # sense if we are in a specialisation, and since my configs always produce
  # `/etc/specialisation` as a file, I can use that to disambiguate the cases.
  if [ -f "/etc/specialisation" ]; then
    log "found '/etc/specialisation', trying to find the main system closure"

    # Find all store paths that reference the specialisation, and remove the
    # specialisation from the output with `grep -v`.
    local referrers="$(nix-store --query --referrers "$current_path" | grep -v "$current_path")"
    log "found all referrers to specialisation closure:"
    log "$referrers"

    # Normally, this should only find 1 store path, the main system closure,
    # since the main system closure references the specialisation closure in
    # `/nix/store/<main-closure>/specialisations/<name>`.
    #
    # Although I do not believe it is possible for there to be more referrers,
    # I'm going to add a safety check to prevent an unexpected scenario.
    if [ "$(echo "$referrers" | wc -l)" != "1" ]; then
      err "found more than 1 root for the specialisation, cannot proceed"
      exit 1
    fi

    log "resolved the actual generation path: $referrers"
    current_path="$referrers"
  fi

  if [ "$(readlink -f "$systemProfile")" = "$current_path" ]; then
    warn "current generation matches latest, nothing to do"
    exit 0
  fi

  log "searching the system profile for matching generation link"
  local found=
  for link in $profilesPath/system-*-link; do
    local link_path="$(readlink -f "$link")"

    if [ "$current_path" = "$link_path" ]; then
      log "found corresponding generation link in system profile: '$link'"

      found=1
      break
    fi
  done

  if [ -z "$found" ]; then
    err "failed to find the generation in the systems profile"
    exit 1
  fi

  local num="$(_extractGenNum "$link")"
  log "resolved generation number as $num"

  info "reverting system profile to current generation"
  run sudo nix-env -p "$systemProfile" --switch-generation "$num"

  info "setting boot loader default to current generation"
  run sudo "$systemProfile/bin/switch-to-configuration" boot
}

rollbackGeneration