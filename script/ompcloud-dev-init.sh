#!/bin/bash
# Initialize docker ompcloud-dev container

# Any subsequent commands which fail will cause the script to exit immediately
set -e

# Build and install libhdfs3
mkdir -p $LIBHDFS3_BUILD
cd $LIBHDFS3_BUILD
cmake $LIBHDFS3_SRC -DCMAKE_BUILD_TYPE=Release -GNinja
ninja
ninja install

# Build llvm/clang
mkdir -p $LLVM_BUILD
cd $LLVM_BUILD
cmake $LLVM_SRC -DLLVM_TARGETS_TO_BUILD="X86" -DCMAKE_BUILD_TYPE=RelWithDebInfo -GNinja
ninja clang omp

# Build libomptarget
mkdir -p $LIBOMPTARGET_BUILD
cd $LIBOMPTARGET_BUILD
cmake -DCMAKE_BUILD_TYPE=Debug $LIBOMPTARGET_SRC
make
