#!/bin/bash
mkdir bundle
cd installer/bin
TMP=$(echo "$(ls -1t | grep "\.ova")" | sed "s/-/-dev-/")
if [ "${DRONE_BUILD_EVENT}" == "push" ] && [ "${DRONE_BRANCH}" != "master" ]; then
   FOLDER=${DRONE_BRANCH}
fi
echo "Passed build will have artifact at https://storage.googleapis.com/vic-product-ova-builds/${FOLDER}${FOLDER:+/}${TMP}"
echo "Renaming build artifact to $TMP..."
mv vic-*.ova ../../bundle/$TMP
cd ../../bundle
ls -l
echo "--------------------------------------------------"
stat --printf="Filesize (%n) = %s\n" $TMP
sha256sum --tag $TMP
sha1sum --tag $TMP
md5sum --tag $TMP
