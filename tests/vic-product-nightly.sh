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

input=$(gsutil ls -l gs://vic-product-ova-builds/vic-* | grep -v TOTAL | sort -k2 -r | head -n1 | xargs | cut -d ' ' -f 3 | cut -d '/' -f 4)
echo "Downloading VIC Product OVA build $input..."
wget -P vic-product https://storage.googleapis.com/vic-product-ova-builds/$input

docker run --net grid --rm --link selenium-hub:selenium-grid-hub -v $PWD/vic-product:/go -v /vic-cache:/vic-cache --env-file vic-internal/vic-product-nightly-secrets.list gcr.io/eminent-nation-87317/vic-integration-test:1.46 pabot --processes 4 --removekeywords TAG:secret --exclude skip tests/manual-test-cases
cat vic-product/pabot_results/*/stdout.txt | grep -E '::|\.\.\.' | grep -E 'PASS|FAIL' > console.log

# Pretty up the email results
sed -i -e 's/^/<br>/g' console.log
sed -i -e 's|PASS|<font color="green">PASS</font>|g' console.log
sed -i -e 's|FAIL|<font color="red">FAIL</font>|g' console.log

DATE=`date +%m-%d-%H-%M`
outfile="vic-product-ova-results-"$DATE".zip"
# zip -9 $outfile output.xml log.html report.html

