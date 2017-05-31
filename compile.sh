#!/usr/bin/env bash

. ./configure.sh

echo "BENCH_COMPILERS: $BENCH_COMPILERS"
echo "BENCH_SIMD: $BENCH_SIMD"
echo "BENCH_SIMD_BACKENDS: $BENCH_SIMD_BACKENDS"

for compiler in "${BENCH_COMPILERS[@]}"; do
   for simdext in "${BENCH_SIMD[@]}"; do
      for simd in "${BENCH_SIMD_BACKENDS[@]}"; do
         build="${compiler}_${simdext}_${simd}"
         echo "compile $build"

         cd build_$build
         make VERBOSE=1
         cd ..

         if [ "$simdext" == "none" ]; then
            break
         fi
      done
   done
done
