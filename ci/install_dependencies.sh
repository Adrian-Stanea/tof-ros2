#!/usr/bin/env bash

# SRC_DIR=$(git rev-parse --show-toplevel 2>/dev/null)

CMAKE_VERSION=${CMAKE_VERSION:-3.20.0}
GLOG_VERSION=${GLOG_VERSION:-0.6.0}
LIBWEBSOCKETS_VERSION=${LIBWEBSOCKETS_VERSION:-3.1}
PROTOBUF_VERSION=${PROTOBUF_VERSION:-3.9.0}
ToF_VERSION=${ToF_VERSION:-5.0.0}

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

install_packages() {
    echo "Installing packages"
    sudo apt-get update -y
    mapfile -t APT_PACKAGES <"$BASE_DIR/apt-packages.txt"
    echo "Installing packages: ${APT_PACKAGES[*]}"
    sudo apt-get install --no-install-recommends -y "${APT_PACKAGES[@]}"
}

install_glog() {
    echo "Installing glog v${GLOG_VERSION}"
    pushd .
    git clone --branch v${GLOG_VERSION} --depth 1 https://github.com/google/glog
    cd glog
    mkdir -p build_"${GLOG_VERSION}" && cd build_"${GLOG_VERSION}"
    sudo cmake .. \
        -DWITH_GFLAGS=off \
        -DCMAKE_INSTALL_PREFIX=/opt/glog
    sudo cmake --build . --target install
    popd || exit
}

install_libwebsockets() {
    echo "Installing libwebsockets v${LIBWEBSOCKETS_VERSION}"
    pushd .
    git clone --branch v${LIBWEBSOCKETS_VERSION}-stable --depth 1 https://github.com/warmcat/libwebsockets
    cd libwebsockets
    mkdir -p build_"${LIBWEBSOCKETS_VERSION}" && cd build_"${LIBWEBSOCKETS_VERSION}"
    sudo cmake .. \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9 \
        -DLWS_STATIC_PIC=ON \
        -DLWS_WITH_SSL=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/websocket
    sudo cmake --build . --target install
    popd || exit
}

install_protobuff() {
    echo "Installing protobuf v${PROTOBUF_VERSION}"
    pushd .
    git clone --branch v"${PROTOBUF_VERSION}" --depth 1 https://github.com/protocolbuffers/protobuf
    cd protobuf
    mkdir -p build_"${PROTOBUF_VERSION}" && cd build_"${PROTOBUF_VERSION}"
    sudo cmake ../cmake \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -Dprotobuf_BUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/protobuf
    sudo cmake --build . --target install
    popd || exit
}

install_ToF_SDK() {
    echo "Installing ToF v${ToF_VERSION}"
    pushd .
    git clone --depth 1 --recurse-submodules --branch v"${ToF_VERSION}" https://github.com/analogdevicesinc/ToF
    cd ToF
    mkdir build && cd build
    sudo cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9 \
        -DWITH_EXAMPLES=off \
        -DWITH_NETWORK=1
    sudo cmake --build . --target install
    popd || exit
}

install_all() {
    install_packages
    install_glog
    install_libwebsockets
    install_protobuff
    install_ToF_SDK
}

for func in "$@"; do
    if declare -f "$func" >/dev/null; then
        "$func"
    else
        echo "Function $func not found in the script."
        exit 1
    fi
done
