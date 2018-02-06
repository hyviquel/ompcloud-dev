#!/bin/bash
# Update ompcloud tools

# Any subsequent commands which fail will cause the script to exit immediately
set -e

# Update LLVM/Clang
echo "Update LLVM/Clang..."
cd $OMPCLOUD_INSTALL_DIR/llvm-build; ninja clang omp

# Update libomptarget
echo "Update libomptarget..."
cd $OMPCLOUD_INSTALL_DIR/libomptarget-build; make

# Update Unibench
#echo "Update Unibench..."
#cd $UNIBENCH_SRC;
