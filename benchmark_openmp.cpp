#include <seqan/seq_io.h>
#include <seqan/basic.h>
#include <seqan/sequence.h>
#include <seqan/stream.h>
#include <seqan/align.h>
#include <iostream>
#include <ctime>
#include <sys/time.h>


using namespace seqan;

typedef String<Dna5> TSequence;
typedef Align<TSequence, ArrayGaps> TAlign;

template<typename TInt>
inline TInt matix_entries(TInt n) {
    return (n*n - n) / 2;
}

int main(int argc, char* argv[])
{
    if (argc < 3) {
      std::cout << "Usage: benchmark_openmp <NumberThreads> <NumberReads>" << std::endl;
      return -1;
    }

    unsigned numThreads = atoi(argv[1]);
    #if defined(_OPENMP)
    omp_set_dynamic(0);
    omp_set_num_threads(numThreads);
    #endif

    unsigned numReads = atoi(argv[2]);
    double start, stop;

    size_t numAlignments = matix_entries(numReads);

    //create all alignment objects
    start = omp_get_wtime();
    StringSet<TAlign> alignments;
    StringSet<TSequence> stringsH, stringsV;

    resize(alignments, numAlignments);
    resize(stringsH, numAlignments);
    resize(stringsV, numAlignments);

    {
        //read batch
        SeqFileIn readsFile("hsapiens_reads.fasta");
        StringSet<CharString> ids;
        StringSet<TSequence> seqs;
        readRecords(ids, seqs, readsFile, numReads);
        close(readsFile);

        //prepare alignments
        for(size_t x = 0; x < numReads; ++x)
            for(size_t y = x + 1; y < numReads; ++y)
                {
                    size_t i = numAlignments - matix_entries(numReads-x) + y - x - 1;
                    TAlign align;
                    resize(rows(align), 2);
                    assignSource(row(align, 0), seqs[x]);
                    assignSource(row(align, 1), seqs[y]);

                    alignments[i] = align;
                    stringsH[i] = seqs[x];
                    stringsV[i] = seqs[y];
                }
    }
    stop = omp_get_wtime();

    numAlignments = length(alignments);
    std::cout << "number of alignments: " << numAlignments << "" << std::endl;
    std::cout << "read data: "  << (stop - start) << " sec" << std::endl;

    String<int> scoresNormScore, scoresSimdScore, scoresNorm, scoresSimd;
    resize(scoresNorm, numAlignments);
    resize(scoresNormScore, numAlignments);

    //default alignments
    //start = omp_get_wtime();
    // #pragma omp parallel for
    //for(size_t x = 0; x < numAlignments; ++x)
    //    scoresNorm[x] = globalAlignment(alignments[x], Score<int, Simple>(2,-2,-1,-3), AlignConfig<true, true, true, true>());
    //stop = omp_get_wtime();
    //std::cout << "time default-traceback: "  << (stop - start) << " sec" << std::endl;

    //simd alignments
    start = omp_get_wtime();
    scoresSimd = globalAlignment(alignments, Score<int, Simple>(2,-2,-1,-3), AlignConfig<true, true, true, true>());
    stop = omp_get_wtime();
    std::cout << "time simd-traceback: "  << (stop - start) << " sec" << std::endl;

    //default score-only alignments
    //start = omp_get_wtime();
    // #pragma omp parallel for
    //for(size_t x = 0; x < numAlignments; ++x)
    //    scoresNormScore[x] = globalAlignmentScore(stringsH[x], stringsV[x], Score<int, Simple>(2,-2,-1,-3), AlignConfig<true, true, true, true>());
    //stop = omp_get_wtime();
    //std::cout << "time default-score: "  << (stop - start) << " sec" << std::endl;

    //simd score-only alignments
    start = omp_get_wtime();
    scoresSimdScore = globalAlignmentScore(stringsH, stringsV, Score<int, Simple>(2,-2,-1,-3), AlignConfig<true, true, true, true>());
    stop = omp_get_wtime();
    std::cout << "time simd-score: "  << (stop - start) << " sec" << std::endl;
/*
    //check scores
    for(size_t x = 0; x < numAlignments; ++x)
        if(scoresNorm[x] != scoresSimd[x])
        {
            // std::cout << scoresCorrect[x] << ": " << scoresNorm[x] << " VS " << scoresSimd[x] << std::endl;
            std::cout << "ERROR!" << std::endl;
            break;
        }

    //check scores
    for(size_t x = 0; x < numAlignments; ++x)
        if(scoresNormScore[x] != scoresSimdScore[x])
        {
            // std::cout << scoresCorrect[x] << ": " << scoresNorm[x] << " VS " << scoresSimd[x] << std::endl;
            std::cout << "ERROR!" << std::endl;
            break;
        }
*/
    return 0;
}
