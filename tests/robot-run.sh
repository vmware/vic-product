#!/bin/bash
# Copyright 2016 VMware, Inc. All Rights Reserved.
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

set -x
gsutil version -l
set +x

dpkg -l > package.list

# check parameters
if [ $# -gt 1 ]; then
    echo "Usage: robot-run.sh <test_suite_option>, runs all tests by default if test_suite_option is not passed"
    exit 1
elif [ $# -eq 1 ]; then
    echo "Running specific test $1 ..."
    run_options=$1
else
    echo "Running all tests by default ..."
    run_options="--removekeywords TAG:secret --exclude skip"
fi

if [ "${DRONE_BUILD_NUMBER}" -eq 0 ]; then
    # get current date time stamp
    now=`date +%Y-%m-%d.%H:%M:%S`
    # run pybot cmd locally
    echo "Running integration tests locally..."
    pybot -d robot-logs/robot-log-$now $run_options tests/test-cases
else
    # run pabot cmd on CI

    echo "Running integration tests on CI..."
    testcases=("tests/test-cases/Group1-OVA-Install" "tests/test-cases/Group2-Getting-Started" "tests/test-cases/Group3-Admiral" "tests/test-cases/Group5-DCH")
    #testcases=("${@:-${DEFAULT_TESTCASES[@]}}")
    #pabot --verbose --processes 1 -d robot-logs --output original.xml $run_options tests/test-cases
    pabot --verbose --processes 3 -d robot-logs --output original_1.xml $run_options "${testcases[@]}"
    
    testcases=("tests/test-cases/Group4-Harbor")
    pabot --verbose --processes 1 -d robot-logs --output original_2.xml $run_options "${testcases[@]}"
    rebot -d robot-logs --merge robot-logs/original_1.xml robot-logs/original_2.xml 
    # do not try re-run if all the tests were passed
    #if [ $? -eq 0 ]; then
    #    echo "All tests passed on first try, no re-run required"
    #    exit 0
    #fi

    # re-run only failed tests and merge results
    #pabot --verbose --processes 3 -d robot-logs --rerunfailed robot-logs/original.xml --output rerun.xml $run_options tests/test-cases
    #rebot -d robot-logs --merge robot-logs/original.xml robot-logs/rerun.xml
fi