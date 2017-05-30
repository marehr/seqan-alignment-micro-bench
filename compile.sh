#!/usr/bin/env zsh

for compiler in "g++-6" "clang++-3.9" "icpc-17"; do
   for simdext in "sse4" "avx2"; do
      for simd in "umesimd" "seqansimd"; do
         build="${compiler}_${simdext}_${simd}"
         echo "compile $build"

         cd build_$build
         make VERBOSE=1
         cd ..
      done
   done
done
