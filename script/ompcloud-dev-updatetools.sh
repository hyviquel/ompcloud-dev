#!/bin/bash
# Update ompcloud tools

# Any subsequent commands which fail will cause the script to exit immediately
set -e

# Update LLVM/Clang
echo "Update LLVM/Clang..."
cd $LLVM_BUILD; ninja clang omp

# Update libomptarget
echo "Update libomptarget..."
cd $LIBOMPTARGET_BUILD; make

# Update Unibench
#echo "Update Unibench..."
#cd $UNIBENCH_SRC;
