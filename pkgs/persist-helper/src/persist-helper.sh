#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH="@path@:$PATH"

logVerbose() {
  echo -n "[persist-helper] " >&2
  echo $@ >&2 # passes arguments raw to `echo` to allow echo to process them as direct arguments (like -n or -e)
}

runVerbose() {
  echo "\$ $@" >&2
  echo "  $($@ 2>&1)" >&2
  echo "" >&2
}

if [ "$#" -ne 4 ]; then
  logVerbose "invalid arguments provided (expected: 4, got: $#)"
  logVerbose "arguments: $@"
  exit 1
fi

operation="$1"
sourceRoot=$(echo "$2" | tr -s '/')
targetRoot=$(echo "$3" | tr -s '/')
sourcePath=$(echo "$sourceRoot/$4" | tr -s '/')
targetPath=$(echo "$targetRoot/${sourcePath#"$sourceRoot"}" | tr -s '/')
parentArray=($(dirname "$4" | tr '/' ' '))

cat <<- EOF >&2
================================================================================
origArgs:     $@

operation:    $operation
sourceRoot:   $sourceRoot
targetRoot:   $targetRoot
sourcePath:   $sourcePath
targetPath:   $targetPath
parentArray:  [ ${parentArray[@]} ]
================================================================================

EOF

if [ "$operation" != "mount" ] && [ "$operation" != "copy" ]; then
  logVerbose "invalid operation (expected one of: [mount, copy], got $operation)"
  exit 1
fi

if [ ! -e "$sourceRoot" ] || [ ! -e "$sourcePath" ]; then
  logVerbose "sources do not exist"
  exit 1
fi

# Accumulate the parents that we know we need to create
# on both the source and target roots. This slowly builds
# up a path string that grows in tandem and points to a
# location which is semantically related.
#
# During the accumulation, we create the contents at the
# target, and perform permission synchronisation from
# the source path accumulated at that point.
#
# As a trivial example, for some input into the CLI:
#   sourceRoot="/"
#   targetRoot="/nix/persist/"
#   parentArray=("var" "lib") # assuming /var/lib/foo is the targetPath
#
# A step by step accumulation would accumulate "var" onto the two roots,
# producing "/var" and "/nix/persist/var", then continues to accumulate
# the "lib", producing "/var/lib" and "/nix/persist/var/lib".
createDirectories() {
  local sourceAcc="$sourceRoot"
  local targetAcc="$targetRoot"

  for parent in ${parentArray[@]}; do
    sourceAcc=$(echo "$sourceAcc/$parent" | tr -s '/')
    targetAcc=$(echo "$targetAcc/$parent" | tr -s '/')

    logVerbose "creating directory '$targetAcc'"
    runVerbose mkdir --verbose --parents "$targetAcc"

    logVerbose "cloning permissions from '$sourceAcc' to '$targetAcc'"
    runVerbose chown --verbose --reference="$sourceAcc" "$targetAcc"
    runVerbose chmod --verbose --reference="$sourceAcc" "$targetAcc"
  done
}

if [ ! -d "$targetRoot" ]; then
  logVerbose "creating target root at '$targetRoot'"
  runVerbose mkdir --parents "$targetRoot"
fi

createDirectories

case "$operation" in
  "mount")
    logEntry="creating entry at '$targetPath' ("
    if [ -f "$sourcePath" ]; then
      logEntry+="file)"
      logVerbose "$logEntry"
      runVerbose touch "$targetPath"
    elif [ -d "$sourcePath" ]; then
      logEntry+="directory)"
      logVerbose "$logEntry"
      runVerbose mkdir "$targetPath"
    fi
    ;;
  "copy")
    logVerbose "copying from '$sourcePath' to '$targetPath'"
    runVerbose cp --archive "$sourcePath" "$targetPath"
    ;;
esac