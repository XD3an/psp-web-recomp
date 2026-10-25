# Shared paths for the build scripts.  tools/ holds the submodules as fetched;
# setup.sh prepares working copies of them in build/.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/build"
FRAMEWORK="$BUILD/PSPRecomp"
TOOLS_BUILD="$BUILD/tools"
PSPDECRYPT="$BUILD/pspdecrypt/pspdecrypt"
EMSDK="$BUILD/emsdk"
