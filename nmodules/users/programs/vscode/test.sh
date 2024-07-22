#!/usr/bin/env sh

JSON_EXPR="$(cat file.json | jq ".")"
LENGTH="$(echo "$JSON_EXPR" | jq '. | length - 1')"
NEW_EXPR="$JSON_EXPR"

for i in $(seq 0 $LENGTH); do
    VALUE=$(echo "$NEW_EXPR" | jq ".[$i]")
    HASH="$(nix-prefetch-url "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$(echo "$VALUE" | jq -r '.publisher')/vsextensions/$(echo "$VALUE" | jq -r '.name')/$(echo "$VALUE" | jq -r '.version')/vspackage")"

    NEW_EXPR="$(echo "$NEW_EXPR" | jq ".[$i].sha256 = \"$HASH\"")"
done

echo "$NEW_EXPR" > file.json