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

input=$(gsutil ls -l gs://vic-product-ova-builds/vic-* | grep -v TOTAL | sort -k2 -r | head -n1 | xargs | cut -d ' ' -f 3 | cut -d '/' -f 4)
echo "Downloading VIC Product OVA build $input..."
wget https://storage.googleapis.com/vic-product-ova-builds/$input -qO

pabot --processes 2 --removekeywords TAG:secret --exclude skip tests/manual-test-cases

DATE=`date +%m-%d-%H-%M`
outfile="vic-product-ova-results-"$DATE".zip"
zip -9 $outfile output.xml log.html report.html

