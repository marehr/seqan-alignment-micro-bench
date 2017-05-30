#!/usr/bin/env zsh

for compiler in "g++-6" "clang++-3.9" "icpc"; do
   for simdext in "sse4" "avx2"; do
      for simd in "umesimd" "seqansimd"; do
         build="${compiler}_${simdext}_${simd}"
         echo "time $build"

         "build_${build}/benchmark_openmp" 1 1000 | tee "results_${build}"
      done
   done
done
