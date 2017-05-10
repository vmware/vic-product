#!/bin/bash
set -e

triggers="^(.drone.yml$|dinv//*)"
mods=$(git --no-pager diff --name-only FETCH_HEAD $(git merge-base FETCH_HEAD master))
namespace="frapposelli"

for mod in $mods; do
  if [[ $mod =~ $triggers ]]; then
    break
  else
    echo "Not testing, build not triggered"
    exit 0
  fi
done

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
  echo "[${name}:${rev}] built"
done
