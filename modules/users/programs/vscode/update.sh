#!/usr/bin/env nix-shell
#! nix-shell -i bash -p cachix git nix

# On a side note, I'm fully aware this script is impure.
# This is intentional, as its a personal script for a personal repository
# and idgaf about reproducing it outside of this context. 
nix run "github:Frontear/code2nix" -- 4 latest > extensions.nix
git add -A
nix build ".#nixosConfigurations.$HOSTNAME.config.my.users.$(whoami).programs.vscode.finalPackage" --no-link --print-out-paths | cachix push frontear
