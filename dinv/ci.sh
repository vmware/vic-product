#!/bin/bash
set -e

triggers="(.drone.yml|dinv//*)"
mods=$(git --no-pager diff --name-only HEAD^1)

namespace="vmware"

if [[ ! $mods =~ $triggers ]]; then
  echo "Not testing, build not triggered"
  exit 0
fi

echo "[registry] logging in as ${DOCKER_USER}"
docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}

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
  docker push "${namespace}/${name}:${rev}"
  echo "[${name}:${rev}] built"
  if [ -f "$version"/LATEST ]; then
    echo "[${name}:${rev}] is tagged as 'latest'"
    docker tag "${namespace}/${name}:${rev}" "${namespace}/${name}:latest"
    docker push "${namespace}/${name}:latest"
  fi
  
done
