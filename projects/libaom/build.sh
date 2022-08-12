#!/bin/bash -eu
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# Build libaom
build_dir=$WORK/build
mkdir -p ${build_dir}
pushd ${build_dir}
# Remove files generated by the previous build.
rm -rf ./*

# oss-fuzz has 2 GB total memory allocation limit. So, we limit per-allocation
# limit in libaom to 1 GB to avoid OOM errors. A smaller per-allocation is
# needed for MemorySanitizer (see bug oss-fuzz:9497 and bug oss-fuzz:9499).
if [[ $CFLAGS = *sanitize=memory* ]]; then
  extra_c_flags='-DAOM_MAX_ALLOCABLE_MEMORY=536870912'
else
  extra_c_flags='-DAOM_MAX_ALLOCABLE_MEMORY=1073741824'
fi
# Also, enable DO_RANGE_CHECK_CLAMP to suppress the noise of integer overflows
# in the transform functions.
extra_c_flags+=' -DDO_RANGE_CHECK_CLAMP=1'

extra_cmake_flags=
# MemorySanitizer requires that all program code is instrumented. Therefore we
# need to replace all inline assembly code that writes to memory with pure C
# code. Disable all assembly code for MemorySanitizer.
if [[ $CFLAGS = *sanitize=memory* ]]; then
  extra_cmake_flags+="-DAOM_TARGET_CPU=generic"
fi

cmake $SRC/aom -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE='-O3 -g' \
  -DCMAKE_CXX_FLAGS_RELEASE='-O3 -g' -DCONFIG_PIC=1 -DCONFIG_LOWBITDEPTH=1 \
  -DCONFIG_AV1_ENCODER=0 -DENABLE_EXAMPLES=0 -DENABLE_DOCS=0 -DENABLE_TESTS=0 \
  -DCONFIG_SIZE_LIMIT=1 -DDECODE_HEIGHT_LIMIT=12288 -DDECODE_WIDTH_LIMIT=12288 \
  -DAOM_EXTRA_C_FLAGS="${extra_c_flags}" \
  -DAOM_EXTRA_CXX_FLAGS="${extra_c_flags}" ${extra_cmake_flags}
make -j$(nproc)
popd

# build fuzzers
fuzzer_src_name=av1_dec_fuzzer
fuzzer_name=${fuzzer_src_name}

$CXX $CXXFLAGS -std=c++11 \
  -I$SRC/aom \
  -I${build_dir} \
  -Wl,--start-group \
  $LIB_FUZZING_ENGINE \
  $SRC/aom/examples/${fuzzer_src_name}.cc -o $OUT/${fuzzer_name} \
  ${build_dir}/libaom.a -Wl,--end-group

# copy seed corpus.
cp $SRC/dec_fuzzer_seed_corpus.zip $OUT/${fuzzer_name}_seed_corpus.zip
cp $SRC/aom/examples/av1_dec_fuzzer.dict $OUT/${fuzzer_name}.dict
