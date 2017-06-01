#!/bin/bash -e
# usage: ./build.sh [versions]
#    ie: ./build.sh
#        to build all Dockerfiles
#    or: ./build.sh ci-linter-1.6
#        to only build ci-linter-1.6

namespace="vmware"

readlink=$(type -p greadlink readlink | head -1)
cd "$(dirname "$(${readlink} -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	name="${version%-*}"
	rev="${version##*-}"
  echo "[${name}:${rev}] Building ${name}:${rev}"
  docker build -t "${namespace}/${name}:${rev}" "$version"
  echo "[${name}:${rev}] You can now push with: \"docker push ${namespace}/${name}:${rev}\""
done
