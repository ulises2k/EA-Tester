#!/usr/bin/env bash
# Script to install MT4 platform using winetricks.
[ -n "$OPT_NOERR" ] || set -e
[ -n "$OPT_TRACE" ] && set -x
CWD="$(cd -P -- "$(dirname -- "$0")" 2>/dev/null && pwd -P || pwd -P)"
WURL=${WURL:-https://raw.githubusercontent.com/kenorb-contrib/winetricks/master/src/winetricks}

# Load the shell functions.
. "$CWD/.funcs.inc.sh"
. "$CWD/.funcs.cmds.inc.sh"

# Prints information of the window status in the background.
set_display
live_stats &

echo "Installing platform..." >&2
sh -xs mt4 < <(wget -qO- $WURL)

echo "Installation successful." >&2
echo "${BASH_SOURCE[0]} done." >&2
