#!/bin/bash -eu
# Copyright 2023 Google LLC
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

cd $SRC/connectedhomeip

# Save OSS-Fuzz C/C++ toolchains envars
CC_SAVE="$(which $CC)"
CXX_SAVE="$(which $CXX)"
CCC_SAVE="$(which $CCC)"

# Activate Pigweed environment
set +u
PW_ENVSETUP_QUIET=1 source scripts/activate.sh
set -u

# Restore saved C/C++ toolchains
export CC="${CC_SAVE}"
export CXX="${CXX_SAVE}"
export CCC="${CCC_SAVE}"

gn gen out/fuzz_targets --args="is_clang=true oss_fuzz=true"
ninja -C out/fuzz_targets fuzz_tests

cp out/fuzz_targets/tests/* $OUT/
