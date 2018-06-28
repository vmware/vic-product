#!/bin/bash
# Copyright 2018 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
set -x

ESX_60_VERSION="ob-5251623"
VC_60_VERSION="ob-5112509"

ESX_65_VERSION="ob-7867845"
VC_65_VERSION="ob-7867539"

ESX_67_VERSION="ob-8169922"
VC_67_VERSION="ob-8217866"

DEFAULT_LOG_UPLOAD_DEST="vic-product-ova-logs"
DEFAULT_BRANCH=""
DEFAULT_BUILD="*"
DEFAULT_TESTCASES=("tests/manual-test-cases")

DEFAULT_VIC_PRODUCT_BRANCH=""
DEFAULT_VIC_PRODUCT_BUILD="*"

DEFAULT_PARALLEL_JOBS=4
DEFAULT_RUN_AS_OPS_USER=0

ARTIFACT_PREFIX="vic-*"
ARTIFACT_BUCKET="vic-product-ova-builds"

start_node () {
    docker run -d --net grid -e HUB_HOST=selenium-hub -v /dev/shm:/dev/shm --name $1 $2

    for i in `seq 1 10`; do
        if [[ "$(docker logs $1)" = *"The node is registered to the hub and ready to use"* ]]; then
            echo "$1 node is up and ready to use";
            return 0;
        fi
        sleep 3;
    done
}

# This is exported to propagate into the pybot processes launched by pabot
export RUN_AS_OPS_USER=${RUN_AS_OPS_USER:-${DEFAULT_RUN_AS_OPS_USER}}

PARALLEL_JOBS=${PARLLEL_JOBS:-${DEFAULT_PARALLEL_JOBS}}
LOG_UPLOAD_DEST="${LOG_UPLOAD_DEST:-${DEFAULT_LOG_UPLOAD_DEST}}"

envfile="$1"

# process the CLI arguments
target="$2"
if [[ ${target} != "6.0" && ${target} != "6.5" && ${target} != "6.7" ]]; then
    echo "Please specify a target version. One of: 6.0, 6.5, 6.7"
    exit 1
else
    echo "Target version: ${target}"
    excludes=("--exclude skip")
    case "$target" in
        "6.0")
            excludes+=("--exclude nsx")
            ESX_BUILD=${ESX_BUILD:-$ESX_60_VERSION}
            VC_BUILD=${VC_BUILD:-$VC_60_VERSION}
            ;;
        "6.5")
            ESX_BUILD=${ESX_BUILD:-$ESX_65_VERSION}
            VC_BUILD=${VC_BUILD:-$VC_65_VERSION}
            ;;
        "6.7")
            excludes+=("--exclude nsx" "--exclude hetero")
            ESX_BUILD=${ESX_BUILD:-$ESX_67_VERSION}
            VC_BUILD=${VC_BUILD:-$VC_67_VERSION}
            ;;
    esac
fi

# drop the first two arguements from the $@ array
shift
shift
# Take the remaining CLI arguments as a test case list - this is treated as an array to preserve quoting when passing to pabot
testcases=("${TEST_CASES:-${DEFAULT_TESTCASES[@]}}")

# Enforce short SHA
GIT_COMMIT=${GIT_COMMIT:0:7}

echo "Kill any old selenium infrastructure..."
docker rm -f selenium-hub firefox1 firefox2 firefox3 firefox4
docker network prune -f

echo "Create the network, hub and workers..."
docker network create grid
docker run -d -p 4444:4444 --net grid --name selenium-hub selenium/hub:3.9.1
for i in `seq 1 10`; do
    if [[ "$(docker logs selenium-hub 2>&1)" = *"Selenium Grid hub is up and running"* ]]; then
        echo 'Selenium Server is up and running';
        break
    fi
    sleep 3;
done

start_node firefox1 selenium/node-firefox:3.9.1
start_node firefox2 selenium/node-firefox:3.9.1
start_node firefox3 selenium/node-firefox:3.9.1
start_node firefox4 selenium/node-firefox:3.9.1

VIC_PRODUCT_BRANCH=${VIC_PRODUCT_BRANCH:-${DEFAULT_VIC_PRODUCT_BRANCH}}
VIC_PRODUCT_BUILD=${VIC_PRODUCT_BUILD:-${DEFAULT_VIC_PRODUCT_BUILD}}
input=$(gsutil ls -l gs://${GCS_BUCKET}/${VIC_PRODUCT_BRANCH}${VIC_PRODUCT_BRANCH:+/}${ARTIFACT_PREFIX}${VIC_PRODUCT_BUILD}-* | grep -v TOTAL | sort -k2 -r | head -n1 | xargs | cut -d ' ' -f 3 | xargs basename)
constructed_url="https://storage.googleapis.com/${GCS_BUCKET}/${VIC_PRODUCT_BRANCH}/${input}"
ARTIFACT_URL="${ARTIFACT_URL:-${constructed_url}}"
input=$(basename ${ARTIFACT_URL})

echo "Downloading VIC Product OVA build $input... from ${ARTIFACT_URL}"
n=0 && rm -f "vic-product/${input}"
until [ $n -ge 5 ]; do
    echo "Retry.. $n"
    echo "Downloading gcp file ${input}"
    wget -nv -O "vic-product/$input" ${ARTIFACT_URL} && break;
    ((n++))
    sleep 10;
done

if [ ! -f  "${input}" ]; then
    echo "VIC Product OVA download failed..quitting the run"
    exit
else
    echo "VIC Product OVA download complete...";
fi

ENV_FILE=${ENV_FILE:-'vic-product-nightly-secrets.list'}
PARLLEL_JOBS=${PARLLEL_JOBS:-${DEFAULT_PARALLEL_JOBS}}
ROBOT_REPORT=${ROBOT_REPORT:-'report'}
docker run --net grid --privileged --rm --link selenium-hub:selenium-grid-hub -v /var/run/docker.sock:/var/run/docker.sock -v /etc/docker/certs.d:/etc/docker/certs.d -v $PWD/vic-product:/go -v /vic-cache:/vic-cache --env-file vic-internal/${ENV_FILE} gcr.io/eminent-nation-87317/vic-integration-test:${Tag} pabot --verbose --processes ${PARALLEL_JOBS} -d ${ROBOT_REPORT} --removekeywords TAG:secret ${excludes[@]}  "${testcases[@]}"
cat vic-product/pabot_results/*/stdout.txt | grep -E '::|\.\.\.' | grep -E 'PASS|FAIL' > console.log

# Pretty up the email results
sed -i -e 's/^/<br>/g' console.log
sed -i -e 's|PASS|<font color="green">PASS</font>|g' console.log
sed -i -e 's|FAIL|<font color="red">FAIL</font>|g' console.log
