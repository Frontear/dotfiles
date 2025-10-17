#!/usr/bin/env zsh

export PATH="@path@:$PATH"

showUsage() {
  echo "Usage: nixos-clean [OPTION]..."
  echo "Clean up old NixOS generations when applicable."
  echo ""
  echo "  -d, --dry-run     show what would be done without doing it"
  echo "  -v, --verbose     increase verbosity of diagnostic messages"
  echo "  -h, --help        display this help and exit"
}

zmodload zsh/zutil
zparseopts -D -E -F - \
  d=dryRun -dry-run=dryRun \
  v=verbose -verbose=verbose \
  h=help -help=help \
  || exit 1

((rmidx=$@[(i)(--|-)]))
set -- "${@[0,rmidx-1]}" "${@[rmidx+1,-1]}"

debug() {
  if [ -n "$verbose" ]; then
    echo "[nixos-clean/DEBUG]: $@"
  fi
}

info() {
  echo "[nixos-clean/INFO]: $@"
}

warn() {
  echo "[nixos-clean/WARN]: $@"
}

err() {
  echo "[nixos-clean/ERROR]: $@"
}

run() {
  if [ -n "$dryRun" ]; then
    echo "$@"
  elif [ -n "$verbose" ]; then
    $@
  else
    $@ 2>/dev/null
  fi
}

if [ -n "$help" ]; then
  showUsage
  exit 0
fi

if [ "$EUID" -ne 0 ]; then
  err "this program requires root priviledges"
  exit 1
fi

globalProfiles=/nix/var/nix/profiles

cleanNixOS() {
  info "cleaning up NixOS generations..."

  local latest="$(readlink -f $globalProfiles/system)"
  debug "resolved system profile to '$latest'"

  for profile in $globalProfiles/system*; do
    debug "found profile '$profile'"
    if [ "$(readlink -f $profile)" != "$latest" ]; then
      debug "deleting profile '$profile'"
      run rm -f "$profile"
    fi
  done

  debug "refreshing boot entries"
  run /run/current-system/bin/switch-to-configuration boot
}

cleanStore() {
  info "cleaning up /nix/store..."

  run nix-collect-garbage -d
}

if [ -f /etc/NIXOS ]; then
  cleanNixOS
fi

cleanStore