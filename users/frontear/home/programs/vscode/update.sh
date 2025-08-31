#!/usr/bin/env nix-shell
#! nix-shell -i bash
#! nix-shell -p git

echo "Do not use this program, it is out of date." >&2
exit 1

if ! nix run "github:Frontear/code2nix" -- $((`nproc` / 4)) latest > extensions-new.nix; then
    echo "Extension update failed"
    exit 1
fi

mv extensions{-new,}.nix
nix build ".#nixosConfigurations.$(hostname).config.home-manager.users.frontear.my.programs.vscode.package" --no-link --print-out-paths
