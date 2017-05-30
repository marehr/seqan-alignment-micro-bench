#!/usr/bin/env bash

./clean.sh
. ./configure.sh

echo "BENCH_COMPILERS: $BENCH_COMPILERS"
echo "BENCH_SIMD: $BENCH_SIMD"
echo "BENCH_SIMD_BACKENDS: $BENCH_SIMD_BACKENDS"

for compiler in "${BENCH_COMPILERS[@]}"; do
   for simdext in "${BENCH_SIMD[@]}"; do
      for simd in "${BENCH_SIMD_BACKENDS[@]}"; do
         build="${compiler}_${simdext}_${simd}"
         simd_uppercase=$(echo "$simd" | tr '[:lower:]' '[:upper:]')
         simdext_uppercase=$(echo "$simdext" | tr '[:lower:]' '[:upper:]')
         echo "build $build"

         mkdir -p build_$build
         cd build_$build

         cmake ../ -DCMAKE_CXX_COMPILER="$compiler" \
               -DSEQAN_CXX_FLAGS="-DSEQAN_${simd_uppercase}_ENABLED=1 -g" \
               -DCMAKE_BUILD_TYPE=Release \
               -DSIMD="${simdext_uppercase}" \
               -DCMAKE_MODULE_PATH=${SEQAN_SRC}/util/cmake \
               -DCMAKE_PREFIX_PATH=${SEQAN_SRC}/util/cmake \
               -DCMAKE_INCLUDE_PATH=${SEQAN_SRC}/include

         cd ..
      done
   done
done
