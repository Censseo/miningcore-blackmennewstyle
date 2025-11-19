#!/bin/bash

OutDir=$1

export UNAME_S=$(uname -s)
export UNAME_P=$(uname -m || uname -p)

AES=$(../Native/check_cpu.sh aes && echo -maes || echo)
SSE2=$(../Native/check_cpu.sh sse2 && echo -msse2 || echo)
SSE3=$(../Native/check_cpu.sh sse3 && echo -msse3 || echo)
SSSE3=$(../Native/check_cpu.sh ssse3 && echo -mssse3 || echo)
PCLMUL=$(../Native/check_cpu.sh pclmul && echo -mpclmul || echo)
AVX=$(../Native/check_cpu.sh avx && echo -mavx || echo)
AVX2=$(../Native/check_cpu.sh avx2 && echo -mavx2 || echo)
AVX512F=$(../Native/check_cpu.sh avx512f && echo -mavx512f || echo)

export CPU_FLAGS="$AES $SSE2 $SSE3 $SSSE3 $PCLMUL $AVX $AVX2 $AVX512F"

HAVE_AES=$(../Native/check_cpu.sh aes && echo -D__AES__ || echo)
HAVE_SSE2=$(../Native/check_cpu.sh sse2 && echo -DHAVE_SSE2 || echo)
HAVE_SSE3=$(../Native/check_cpu.sh sse3 && echo -DHAVE_SSE3 || echo)
HAVE_SSSE3=$(../Native/check_cpu.sh ssse3 && echo -DHAVE_SSSE3 || echo)
HAVE_PCLMUL=$(../Native/check_cpu.sh pclmul && echo -DHAVE_PCLMUL || echo)
HAVE_AVX=$(../Native/check_cpu.sh avx && echo -DHAVE_AVX || echo)
HAVE_AVX2=$(../Native/check_cpu.sh avx2 && echo -DHAVE_AVX2 || echo)
HAVE_AVX512F=$(../Native/check_cpu.sh avx512f && echo -DHAVE_AVX512F || echo)

export HAVE_FEATURE="$HAVE_AES $HAVE_SSE2 $HAVE_SSE3 $HAVE_SSSE3 $HAVE_PCLMUL $HAVE_AVX $HAVE_AVX2 $HAVE_AVX512F"

# Function to build external dependencies with caching
# Usage: build_external_dep "project_name" "git_url" "commit_hash" "native_lib_dir" "cmake_flags" "lib_filename"
build_external_dep() {
    local PROJECT=$1
    local GIT_URL=$2
    local COMMIT=$3
    local NATIVE_DIR=$4
    local CMAKE_FLAGS=$5
    local LIB_FILE=$6

    local MARKER_FILE="../Native/$NATIVE_DIR/.build-marker"
    local LIB_PATH="../Native/$NATIVE_DIR/$LIB_FILE"

    # Check if we should skip the build
    if [ -f "$LIB_PATH" ] && [ -f "$MARKER_FILE" ]; then
        local CACHED_COMMIT=$(cat "$MARKER_FILE")
        if [ "$CACHED_COMMIT" = "$COMMIT" ] && [ -z "$FORCE_REBUILD_EXTERNAL" ]; then
            echo "Using cached $PROJECT (commit: $COMMIT)"
            return 0
        fi
    fi

    echo "Building $PROJECT from source (commit: $COMMIT)..."

    # Clone and build
    (cd /tmp && \
     rm -rf "$PROJECT" && \
     git clone "$GIT_URL" "$PROJECT" && \
     cd "$PROJECT" && \
     git checkout "$COMMIT" && \
     mkdir -p build && \
     cd build && \
     eval "cmake $CMAKE_FLAGS .." && \
     cmake --build . -j$(nproc) || true)  # Continue even if tests fail

    # Check if library was built successfully
    if [ ! -f "/tmp/$PROJECT/build/$LIB_FILE" ]; then
        echo "ERROR: Failed to build $LIB_FILE for $PROJECT"
        return 1
    fi

    # Copy library and create marker
    cp "/tmp/$PROJECT/build/$LIB_FILE" "../Native/$NATIVE_DIR/" && \
    echo "$COMMIT" > "$MARKER_FILE"
}

(cd ../Native/libmultihash && make) && mv ../Native/libmultihash/libmultihash.so "$OutDir"
(cd ../Native/libbeamhash && make) && mv ../Native/libbeamhash/libbeamhash.so "$OutDir"
(cd ../Native/libetchash && make) && mv ../Native/libetchash/libetchash.so "$OutDir"
(cd ../Native/libethhash && make) && mv ../Native/libethhash/libethhash.so "$OutDir"
(cd ../Native/libethhashb3 && make -j) && mv ../Native/libethhashb3/libethhashb3.so "$OutDir"
(cd ../Native/libubqhash && make) && mv ../Native/libubqhash/libubqhash.so "$OutDir"
(cd ../Native/libcryptonote && make) && mv ../Native/libcryptonote/libcryptonote.so "$OutDir"
(cd ../Native/libcryptonight && make) && mv ../Native/libcryptonight/libcryptonight.so "$OutDir"
(cd ../Native/libverushash && make) && mv ../Native/libverushash/libverushash.so "$OutDir"
(cd ../Native/libfiropow && make) && mv ../Native/libfiropow/libfiropow.so "$OutDir"
(cd ../Native/libkawpow && make) && mv ../Native/libkawpow/libkawpow.so "$OutDir"
(cd ../Native/libmeowpow && make) && mv ../Native/libmeowpow/libmeowpow.so "$OutDir"
(cd ../Native/libdero && make) && mv ../Native/libdero/libdero.so "$OutDir"
(cd ../Native/libcortexcuckoocycle && make) && mv ../Native/libcortexcuckoocycle/libcortexcuckoocycle.so "$OutDir"
(cd ../Native/libprogpowz && make) && mv ../Native/libprogpowz/libprogpowz.so "$OutDir"
(cd ../Native/libzanonote && make) && mv ../Native/libzanonote/libzanonote.so "$OutDir"
(cd ../Native/libmerakipow && make) && mv ../Native/libmerakipow/libmerakipow.so "$OutDir"
(cd ../Native/libphihash && make) && mv ../Native/libphihash/libphihash.so "$OutDir"
(cd ../Native/libsccpow && make) && mv ../Native/libsccpow/libsccpow.so "$OutDir"

# Build external dependencies with caching
build_external_dep "secp256k1" "https://github.com/bitcoin-ABC/secp256k1" "04fabb44590c10a19e35f044d11eb5058aac65b2" "libnexapow" "-GNinja -DCMAKE_C_FLAGS=-fPIC -DSECP256K1_ENABLE_MODULE_RECOVERY=OFF -DSECP256K1_ENABLE_COVERAGE=OFF -DSECP256K1_ENABLE_MODULE_SCHNORR=ON" "libsecp256k1.a"
(cd ../Native/libnexapow && make) && mv ../Native/libnexapow/libnexapow.so "$OutDir"

build_external_dep "RandomX" "https://github.com/tevador/RandomX" "v1.2.1" "librandomx" "-DARCH=native -DCMAKE_C_FLAGS=-Wa,--noexecstack -DCMAKE_CXX_FLAGS=-Wa,--noexecstack" "librandomx.a"
(cd ../Native/librandomx && make) && mv ../Native/librandomx/librandomx.so "$OutDir"

build_external_dep "RandomARQ" "https://github.com/arqma/RandomARQ" "3bcb6bafe63d70f8e6f78a0d431e71be2b638083" "librandomarq" "-DARCH=native -DCMAKE_C_FLAGS=-Wa,--noexecstack -DCMAKE_CXX_FLAGS=-Wa,--noexecstack" "librandomx.a"
(cd ../Native/librandomarq && make) && mv ../Native/librandomarq/librandomarq.so "$OutDir"

build_external_dep "Panthera" "https://github.com/scala-network/Panthera" "cc7425f468d935ba328fba5bbb05f8227f4f22d7" "libpanthera" "-DARCH=native -DCMAKE_C_FLAGS=-Wa,--noexecstack -DCMAKE_CXX_FLAGS=-Wa,--noexecstack" "librandomx.a"
(cd ../Native/libpanthera && make) && mv ../Native/libpanthera/libpanthera.so "$OutDir"

build_external_dep "RandomXSCash" "https://github.com/scashnetwork/RandomX" "0b3e0ded68b95491516fe974e3db784ca2742ca7" "librandomxscash" "-DARCH=native -DCMAKE_C_FLAGS=-Wa,--noexecstack -DCMAKE_CXX_FLAGS=-Wa,--noexecstack" "librandomx.a"
(cd ../Native/librandomxscash && make) && mv ../Native/librandomxscash/librandomxscash.so "$OutDir"
