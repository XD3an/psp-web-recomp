#!/usr/bin/env bash
# Entry point of "docker compose up": ports each disc image in games/ and
# serves it.  Ports run again on every start so that changes are picked up;
# port.sh prepares the checkout first and skips the steps already done.  The
# file name gives the game's name: games/My Game.iso is ported as my_game.
# With several games, GAME=<name> docker compose up picks the one to serve.
# OPTS is passed on to port.sh, e.g. OPTS="--native --opt 2".
set -euo pipefail
source "$(dirname "$0")/common.sh"
here="$(dirname "$0")"

shopt -s nullglob nocaseglob
names=()
for image in "$ROOT"/games/*.iso "$ROOT"/games/*.zip "$ROOT"/games/*.7z; do
  base="$(basename "$image")"
  name="$(printf '%s' "${base%.*}" | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '_' | sed 's/^_//; s/_$//')"
  names+=("$name")
  "$here/port.sh" "$name" "$image" ${OPTS:-}  # split on purpose
done

if [ -n "${GAME:-}" ]; then
  game="$GAME"
elif [ ${#names[@]} -eq 1 ]; then
  game="${names[0]}"
elif [ ${#names[@]} -eq 0 ]; then
  echo "No game yet: put a disc image of a game you own in games/ (.iso, .zip or .7z)" >&2
  echo "and run docker compose up again." >&2
  exit 1
else
  echo "Several games in games/: ${names[*]}" >&2
  echo "Pick the one to serve with GAME=<name> docker compose up" >&2
  exit 1
fi
echo "== serving $game: open http://localhost:${PORT:-8613}/"
exec "$here/serve.sh" "$game" "${PORT:-8613}"
