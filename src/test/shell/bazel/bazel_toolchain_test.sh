#!/bin/bash
#
# Copyright 2016 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Tests compiling using an external toolchain
#

# Load test environment
source $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/test-setup.sh \
  || { echo "test-setup.sh not found!" >&2; exit 1; }

# Copy the project package here
cp -r ${testdata_path}/bazel_toolchain_test_data/* .

# Rename WORKSPACE.linaro file to WORKSPACE
# (Did not include the file WORKSPACE in the test because source tree under
# directories that contain this file is not parsed)
mv WORKSPACE.linaro WORKSPACE

bazel clean --expunge
bazel build --crosstool_top=//tools/arm_compiler:toolchain --cpu=armeabi-v7a \
  --spawn_strategy=standalone hello || fail "Should build"

# Assert that output binary exists
test -f ./bazel-bin/hello || fail "output not found"

# Assert that output has the right machine architecture
file ./bazel-bin/hello | grep -q "ARM" || fail "expect ARM machine architecture"
file ./bazel-bin/hello | grep -q "x86-64" && fail "expect ARM machine architecture"

echo "PASS"

