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
  if [ -x "$(command -v gas)" ]; then
    echo "Running go AST tool (gas) for ${version}/ directory. This step will fail if gas generates any warnings."
    echo "(Use #nosec comments to annotate innocuous code with gas warnings.)"
    gas -quiet "${version}"/... 2> /dev/null
  else
    echo "go AST tool (gas) not present, skipping gas check."
  fi

  name="${version%-*}"
  rev="${version##*-}"
  echo "[${name}:${rev}] Building ${name}:${rev}"
  docker build -t "${namespace}/${name}:${rev}" "$version"
  echo "[${name}:${rev}] You can now push with: \"docker push ${namespace}/${name}:${rev}\""
done
