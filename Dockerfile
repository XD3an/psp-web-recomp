# Toolchain for the scripts.  The checkout is mounted at /work and setup.sh
# installs the Emscripten SDK into its build/, as it does without Docker.
FROM ubuntu:24.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates git cmake ninja-build make g++ python3 xz-utils p7zip-full \
      libegl-dev libgles-dev zlib1g-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*
# The scripts take a decrypter called as "<tool> <in> <out>" (PSP_DECRYPT) and
# one for updaters (PSP_PSAR_DECRYPT); pspdecrypt, which setup.sh builds into
# build/, serves as both but takes "-o <out> <in>".
RUN printf '#!/bin/sh\nexec /work/build/pspdecrypt/pspdecrypt -o "$2" "$1" > /dev/null\n' > /usr/local/bin/decrypt-eboot \
    && chmod 755 /usr/local/bin/decrypt-eboot
ENV HOME=/tmp PSP_DECRYPT=/usr/local/bin/decrypt-eboot PSP_PSAR_DECRYPT=/work/build/pspdecrypt/pspdecrypt
WORKDIR /work
