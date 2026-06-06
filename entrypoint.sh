#!/usr/bin/env sh
# Launch the MegaMek dedicated (headless) server.
#
# Configurable via environment variables:
#   MM_XMX        Max JVM heap            (default 4096m)
#   MM_PORT       Server port            (default: MegaMek default 2346)
#   MM_SAVEGAME   Saved game to load     (e.g. savegames/mygame.sav.gz)
#   MM_EXTRA_ARGS Extra args passed to MegaMek
#
# Any arguments passed to the container are appended verbatim.
set -eu

ARGS="-dedicated"

if [ -n "${MM_PORT:-}" ]; then
  ARGS="$ARGS -port $MM_PORT"
fi

if [ -n "${MM_EXTRA_ARGS:-}" ]; then
  ARGS="$ARGS $MM_EXTRA_ARGS"
fi

# A savegame, if any, must come last on the dedicated-server command line.
if [ -n "${MM_SAVEGAME:-}" ]; then
  ARGS="$ARGS $MM_SAVEGAME"
fi

set -x
exec java \
  -Xmx"${MM_XMX:-4096m}" \
  -Djava.awt.headless=true \
  -Dsun.awt.disablegrab=true \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.util.concurrent=ALL-UNNAMED \
  -jar MegaMek.jar $ARGS "$@"
