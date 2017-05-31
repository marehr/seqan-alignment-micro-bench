#!/usr/bin/env bash

. ./configure.sh

echo "BENCH_COMPILERS: ${BENCH_COMPILERS[*]}"
echo "BENCH_SIMD: ${BENCH_SIMD[*]}"
echo "BENCH_SIMD_BACKENDS: ${BENCH_SIMD_BACKENDS[*]}"

for compiler in "${BENCH_COMPILERS[@]}"; do
   for simdext in "${BENCH_SIMD[@]}"; do
      for simd in "${BENCH_SIMD_BACKENDS[@]}"; do
         threads="1"
         while [ $threads -le $BENCH_MAX_THREADS ]; do
            build="${compiler}_${simdext}_${simd}"
            echo "benchmark $build:$threads"

            "build_${build}/benchmark_openmp" "$threads" "$BENCH_NUMBER_OF_ALIGNMENTS" | tee "results_${build}"
            echo
            threads=$[$threads*2]
         done

         if [ "$simdext" == "nosimd" ]; then
            break
         fi
      done
   done
done
