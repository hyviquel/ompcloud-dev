#!/bin/bash
# Initialize docker ompcloud-dev container

# Any subsequent commands which fail will cause the script to exit immediately
set -e

# Build and install libhdfs3
mkdir -p $OMPCLOUD_INSTALL_DIR/libhdfs3-build
cd $OMPCLOUD_INSTALL_DIR/libhdfs3-build
cmake $OMPCLOUD_INSTALL_DIR/libhdfs3 -DCMAKE_BUILD_TYPE=Release -GNinja
ninja
ninja install

# Build llvm/clang
mkdir -p $OMPCLOUD_INSTALL_DIR/llvm-build
cd $OMPCLOUD_INSTALL_DIR/llvm-build
cmake $OMPCLOUD_INSTALL_DIR/llvm -DLLVM_TARGETS_TO_BUILD="X86" -DCMAKE_BUILD_TYPE=Release -GNinja
ninja clang omp

# Build libomptarget
mkdir -p $OMPCLOUD_INSTALL_DIR/libomptarget-build
cd $OMPCLOUD_INSTALL_DIR/libomptarget-build
cmake -DCMAKE_BUILD_TYPE=Debug $OMPCLOUD_INSTALL_DIR/libomptarget
make
