#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# We want to be an extremely thin wrapper around `app2unit`. If there is only
# one argument given, and it matches with an expected application or .desktop
# file, then we will perform our wrapping. In all other cases, we will not do
# anything, and just pass arguments as is to the underlying application, to
# prevent breaking expected functionality.
#
# More directly, for this wrapper to be effective, the caller must ONLY provide
# a single argument (or a single argument after `--`): a path to a binary, or a
# .desktop file. This wrapper will then determine if the argument warrants any
# wrapping. If it does, then it will attach arguments as needed and re-invoke
# the underlying program. If not, then the underlying application is invoked
# with all arguments passed directly to it.

# `app2unit` accepts binary files or .desktop files to be specified after an
# end-of-options `--` specifier. We will account for that by shifting it.
if [ "$1" = "--" ]; then
  shift
fi

if [ "$#" -eq 1 ]; then
  case "$1" in
    # Run Microsoft Edge as a service to link it with the other scope unit
    # that comes up with it. This prevents a race condition during shutdown
    # that causes unclean termination.
    #
    # see: https://github.com/hyprwm/Hyprland/discussions/8459#discussioncomment-14063563
    *microsoft-edge|*microsoft-edge.desktop|*com.microsoft.Edge.desktop)
      exec "@app2unit@" -t service -- "$1"
      ;;
  esac
fi

# Will never be reached if any `case` branch succeeds.
#
# NOTE: `-a "$0"` needed because this application has symlinks to the main
# binary which change the behaviour of execution. The symlink name, which will
# be seen in `$0`, determines this change.
exec -a "$0" "@app2unit@" "$@"