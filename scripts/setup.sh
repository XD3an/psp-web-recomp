#!/usr/bin/env bash
# Prepares a fresh checkout: fetches the submodules in tools/ (PSPRecomp,
# pspdecrypt and the Emscripten SDK) and makes working copies of them in build/,
# where PSPRecomp gets the patches and the web profile, pspdecrypt is compiled
# and the Emscripten SDK installed.  tools/ stays as fetched.  Safe to run again.
#   scripts/setup.sh [--no-emsdk]
set -euo pipefail
source "$(dirname "$0")/common.sh"

EMSDK_VERSION="6.0.11"

# Clones the submodule tools/<name> into build/<name>, at the same commit.
clone_tool() {
  rm -rf "$BUILD/$1"
  git clone -q --no-checkout "$ROOT/tools/$1" "$BUILD/$1"
  git -C "$BUILD/$1" checkout -q --detach "$(git -C "$ROOT/tools/$1" rev-parse HEAD)"
}

git -C "$ROOT" submodule update --init --recursive

if [ ! -d "$FRAMEWORK/.git" ]; then
  echo "== fetching PSPRecomp"
  clone_tool PSPRecomp
  git -C "$FRAMEWORK" checkout -q -b web
  git -C "$FRAMEWORK" -c user.name=setup -c user.email=setup@localhost am -q "$ROOT"/patches/*.patch
fi

if [ ! -e "$FRAMEWORK/profiles/web" ]; then
  ln -sfn ../../../app "$FRAMEWORK/profiles/web"
  grep -qx "profiles/web" "$FRAMEWORK/.git/info/exclude" 2>/dev/null || echo "profiles/web" >> "$FRAMEWORK/.git/info/exclude"
fi

if [ ! -x "$PSPDECRYPT" ]; then
  echo "== building pspdecrypt"
  clone_tool pspdecrypt
  make -C "$BUILD/pspdecrypt" -j "${JOBS:-8}" CC=cc CXX=c++ >/dev/null \
    || echo "pspdecrypt did not build (it needs the zlib and OpenSSL headers)" >&2
fi

if [ "${1:-}" != "--no-emsdk" ] && [ ! -f "$EMSDK/emsdk_env.sh" ]; then
  echo "== installing the Emscripten SDK $EMSDK_VERSION"
  clone_tool emsdk
  "$EMSDK/emsdk" install "$EMSDK_VERSION"
  "$EMSDK/emsdk" activate "$EMSDK_VERSION"
fi

"$(dirname "$0")/build_tools.sh"
echo "== ready"
