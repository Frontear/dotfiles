#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH="@path@:$PATH"

ss_dir="$HOME/Pictures/Screenshots"
ss_folder=$(date '+%Y-%m')
ss_name=$(date '+%e_%Hh%Mm%Ss')

# Ensure folder exists before capturing the screen
mkdir -p "$ss_dir/$ss_folder"

# Capture the screenshot, save it to the designated path, and copy it to the clipboard.
grim -cg "$(slurp)" - | tee "$ss_dir/$ss_folder/$ss_name" | wl-copy
