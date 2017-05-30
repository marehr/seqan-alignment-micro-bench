cmake_minimum_required(VERSION 3.0)
project(benchmark_openmp CXX)

# require c++14
if (CMAKE_VERSION GREATER 3.1.0)
  set(CMAKE_CXX_STANDARD 14)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CXX11_FOUND TRUE)
else ()
  set(CMAKE_CXX_FLAGS "-std=c++14")
endif ()

# require sse4
# set(SEQAN_ARCH_SSE4 ON)

find_package (OpenMP)
find_package (SeqAn REQUIRED)
include (SeqAnSimdUtility)

message (STATUS "SIMD: ${SIMD}")
set (SEQAN_CXX_FLAGS "${SEQAN_CXX_FLAGS}" ${SEQAN_SIMD_${SIMD}_OPTIONS})
message (STATUS "SIMD: ${SEQAN_CXX_FLAGS} build")

# Was SeqAn included?
if (NOT (SEQAN_FOUND))
    message (FATAL_ERROR "SeqAn not found")
endif ()

# Set Release mode
set(CMAKE_BUILD_TYPE "Release")

# Add include directories.
include_directories (${SEQAN_INCLUDE_DIRS})

# Add definitions set by find_package (SeqAn).
add_definitions (${SEQAN_DEFINITIONS})

# Add CXX flags found by find_package (SeqAn).
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SEQAN_CXX_FLAGS} ")

set(SOURCE_FILES benchmark_openmp.cpp)
add_executable(benchmark_openmp ${SOURCE_FILES})

target_link_libraries(benchmark_openmp ${ZLIB_LIBRARIES} pthread)
