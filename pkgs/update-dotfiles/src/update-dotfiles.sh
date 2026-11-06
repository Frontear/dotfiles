#!/usr/bin/env zsh

showUsage() {
  echo "Usage: $(basename $0) [OPTION]..."
  echo "Update the flake lock file and other relevant artifacts."
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
    echo "[update-dotfiles/DEBUG]: $@"
  fi
}

info() {
  echo "[update-dotfiles/INFO]: $@"
}

warn() {
  echo "[update-dotfiles/WARN]: $@"
}

err() {
  echo "[update-dotfiles/ERROR]: $@"
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

if [ "$EUID" -eq 0 ]; then
  err "please do not run this script as root."
  exit 1
fi

if [ ! -f "$PWD/flake.lock" ]; then
  err "please run this script from the repository root."
  exit 1
fi

updateLock() {
  info "updating 'flake.lock'"
  run nix flake update

  # TODO: iterate over all flakes found on the system and update their lock files?
}

updateVSCodeExts() {
  pushd "$PWD/users/frontear/home/programs/vscode" > /dev/null

  info "updating VSCode extensions"

  # safety to prevent issues from changing the extensions.nix file
  if ! run nix run "github:Frontear/code2nix" -- -f "$PWD/extensions.nix" -o "$PWD/extensions.nix.new"; then
    err "failed to update vscode extensions."
    exit 1
  fi

  # atomically replace
  run mv "$PWD/extensions.nix"{.new,}

  # pretty-format (TODO: make this part of code2nix?)
  run nix run "nixpkgs#nixfmt" -- "$PWD/extensions.nix"

  popd > /dev/null
}

# TODO: automatically force `nix flake check`?
# TODO: automatically submit a commit, specifically after check?
updateLock
updateVSCodeExts