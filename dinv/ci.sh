#!/bin/bash
set -e

function changeset {
  case "$DRONE_BUILD_EVENT" in
  'pull_request')
    base=$(curl -s -H "Authorization: token ${GITHUB_AUTOMATION_API_KEY}" "https://api.github.com/repos/${DRONE_REPO_OWNER}/${DRONE_REPO_NAME}/pulls/${DRONE_PULL_REQUEST}" | jq -r .base.sha)
    ;;
  'push')
    base=$(curl -s -H "Authorization: token ${GITHUB_AUTOMATION_API_KEY}" "https://api.github.com/repos/${DRONE_REPO_OWNER}/${DRONE_REPO_NAME}/commits/${DRONE_COMMIT_SHA}" | jq -r .parents[0].sha)
    ;;
  'tag')
    # no changeset generated for tagging
    return
    ;;
  *)
    echo "Unknown build type: ${DRONE_BUILD_EVENT}" >&2
    exit 1
    ;;
  esac

  echo "$base..$DRONE_COMMIT_SHA"
}

triggers="(.drone.yml|dinv//*)"
cs=$(changeset)
mods=$(git --no-pager diff --name-only "$cs")

git_rev=$(git rev-parse HEAD)

namespace="vmware"
project="default-project"

mkdir -p /etc/docker/certs.d/${HARBOR_CI_REGISTRY}
pushd /etc/docker/certs.d/${HARBOR_CI_REGISTRY}
echo "$(openssl s_client -showcerts -connect ${HARBOR_CI_REGISTRY}:443 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')" > ca.crt
echo "$(cat ca.crt)"
popd

if [[ ! $mods =~ $triggers ]]; then
  echo "Not testing, build not triggered"
  echo "Modified file list:"
  echo "$mods"
  exit 0
fi

readlink=$(type -p greadlink readlink | head -1)
cd "$(dirname "$(${readlink} -f "$BASH_SOURCE")")"

function build {
  echo "${HARBOR_CI_REGISTRY} logging in as ${TEST_USERNAME}"
  docker login ${HARBOR_CI_REGISTRY} -u "${TEST_USERNAME}" -p "${TEST_PASSWORD}"

  versions=( "$@" )
  if [ ${#versions[@]} -eq 0 ]; then
    versions=( */ )
  fi
  versions=( "${versions[@]%/}" )

  for version in "${versions[@]}"; do
    name="${version%-*}"
    rev="${version##*-}"
    echo "[${name}:${rev}] Building ${name}:${rev}"
    docker build -t "${namespace}/${name}:${rev}-${git_rev}" "$version"
    docker tag "${namespace}/${name}:${rev}-${git_rev}" "${namespace}/${name}:${rev}"
    echo "[${name}:${rev}] built"
    docker tag "${namespace}/${name}:${rev}-${git_rev}" "${HARBOR_CI_REGISTRY}/${project}/${name}:${rev}"
    docker push "${HARBOR_CI_REGISTRY}/${project}/${name}:${rev}"
    echo "[${HARBOR_CI_REGISTRY}/${project}/${name}:${rev}] pushed"
  done

}

function push {
  echo "[registry] logging in as ${DOCKER_USER}"
  docker login -u "${DOCKER_USER}" -p "${DOCKER_PASSWORD}"

  versions=( "$@" )
  if [ ${#versions[@]} -eq 0 ]; then
    versions=( */ )
  fi
  versions=( "${versions[@]%/}" )

  for version in "${versions[@]}"; do
    name="${version%-*}"
    rev="${version##*-}"
    echo "[${name}:${rev}] pushing ${name}:${rev}"
    docker push "${namespace}/${name}:${rev}-${git_rev}"
    docker push "${namespace}/${name}:${rev}"
    echo "[${name}:${rev}] built"
    if [ -f "$version"/LATEST ]; then
      echo "[${name}:${rev}] is tagged as 'latest'"
      docker tag "${namespace}/${name}:${rev}" "${namespace}/${name}:latest"
      docker push "${namespace}/${name}:latest"
    fi
  done

}


function usage {
  echo $"Usage: $0 {build|push}"
  exit 1
}

if [ $# -gt 0 ]; then
  case "$1" in
    build)
      build
      ;;
    push)
      push
      ;;         
    *)
      usage
  esac
else
  usage
fi
