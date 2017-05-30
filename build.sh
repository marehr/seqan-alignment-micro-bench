#!/usr/bin/env zsh

SEQAN_SRC=~/develope/seqan-src

./clean.sh

for compiler in "g++-6" "clang++-3.9" "icpc-17"; do
   for simdext in "sse4" "avx2"; do
      for simd in "umesimd" "seqansimd"; do
         build="${compiler}_${simdext}_${simd}"
         echo "build $build"

         mkdir -p build_$build
         cd build_$build

         cmake ../ -DCMAKE_CXX_COMPILER="$compiler" \
               -DSEQAN_CXX_FLAGS="-DSEQAN_${simd:u}_ENABLED=1 -g" \
               -DCMAKE_BUILD_TYPE=Release \
               -DSIMD="${simdext:u}" \
               -DCMAKE_MODULE_PATH=${SEQAN_SRC}/util/cmake \
               -DCMAKE_PREFIX_PATH=${SEQAN_SRC}/util/cmake \
               -DCMAKE_INCLUDE_PATH=${SEQAN_SRC}/include

         cd ..
      done
   done
done
