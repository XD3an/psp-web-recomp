#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
name="$1"
[ -x "$TOOLS_BUILD/psp_recomp" ] || "$(dirname "$0")/build_tools.sh"
"$TOOLS_BUILD/psp_recomp" --dynamic "$ROOT/games/$name/root/dynamic.txt" "$ROOT/app/generated/$name/dynamic_code.cpp"
