#!/bin/bash
# Run execution for ompcloud

# Any subsequent commands which fail will cause the script to exit immediately
set -e

UNIBENCH_BUILD_TEST="/opt/Unibench-build-test"
TESTED_CC="$LLVM_BUILD/bin/clang"

TEST_LIST="2,2,,2,4,5,6,7,8,15,16,18"
BENCHMARK_LIST="2,2,,2,4,9,11,14,15,18,19"

CTEST_ARG="--output-on-failure"

QUICK=false
RESET=true
BENCH=false

while [[ $# -ge 1 ]]
do
  key="$1"

  case $key in
    -q|--quick)
    QUICK=true
    ;;
    -b|--benchmark)
    BENCH=true
    ;;
    -n|--noreset)
    RESET=false
    ;;
    -v|--verbose)
    CTEST_ARG="$CTEST_ARG --verbose"
    ;;
    *)
    # unknown option
    ;;
  esac
  shift # past argument or value
done

export UNIBENCH_BUILD_TEST=$UNIBENCH_BUILD_TEST
export CC=$TESTED_CC

if [ "$RESET" = true ]; then
  echo "-- RESET OLD EXECUTION --"
  # Initialize HDFS server
  hdfs-reset
  rm -rf $UNIBENCH_BUILD_TEST
fi

# Build Unibench
mkdir -p $UNIBENCH_BUILD_TEST
cd $UNIBENCH_BUILD_TEST
cmake $UNIBENCH_SRC -DCMAKE_BUILD_TYPE=Release -DRUN_TEST=ON

if [ "$QUICK" = true ]; then
  make mat-mul
elif [ "$BENCH" = true ]; then
  make experiments
else
  make supported
fi

# Run experiments
if [ "$QUICK" = true ]; then
  ctest -R "mgBench_mat-mul" $CTEST_ARG
elif [ "$BENCH" = true ]; then
  ctest -I $BENCHMARK_LIST $CTEST_ARG
else
  ctest -I $TEST_LIST $CTEST_ARG
fi
