# VIC Product OVA Build

The build process uses a collection of bash scripts to launch a docker container on your local machine
where we provision a linux OS, install VIC dependencies, and extract the filesystem to make the OVA.

## Usage

The build process is controlled from a central script, `build.sh`. This script
launches the build docker container and controls our provisioning and ova
extraction through `make`.

### Prerequisites

The build machine must have `docker` and if using `build.sh` must have `gsutil`.

- `gsutil`: https://cloud.google.com/sdk/downloads
- `docker for Mac`: https://www.docker.com/docker-mac
- `docker for Windows`: https://www.docker.com/docker-windows

### Build bundle and OVA

#### Build script

This is the recommended way to build the OVA.


The build script pulls the desired versions of each included component into the build container.
It accepts files in `scripts`, URLs, or revisions and automatically sets
required environment variables.

If called without any values, `build.sh` will get the latest build for each component
```
./scripts/build.sh
```

If called with the values below, `build.sh` will include the Harbor version from
`packer/scripts/harbor.tgz`, the VIC Engine version from `packer/scripts/vic.tar.gz`, and 
Admiral tag `vic_dev` (since `--admiral` was not specified it defaults to the `vic_dev` tag)
```
./scripts/build.sh --harbor harbor.tgz --vicengine vic.tar.gz
```

If called with the values below, `build.sh` will include the Harbor and VIC Engine versions
specified by their respective URLs, and Admiral tag `vic_v1.1.1`
```
./scripts/build.sh --admiral v1.1.1 --harbor https://example.com/harbor.tgz --vicengine https://example.com/vic.tar.gz
```

#### Manual

This method of building the OVA is not recommended as it is more complicated.

First, we have to set the revisions of the components we want to bundle in the OVA.
Specifying a file takes precedence, then URL, then revision.

Pick one to set VIC Engine version:

```
export BUILD_VICENGINE_REVISION=1.1.1                      # If specifying file or URL, REVISION is used for setting UI plugin version
                                                           # If no other BUILD_VICENGINE vars specified, also specifies VIC Engine
                                                           # version from https://console.cloud.google.com/storage/browser/vic-engine-releases
export BUILD_OVA_REVISION=$(git describe --tags)           # Set the OVA version displayed in the
                                                           # OVA deploy wizard and version files on disk
export BUILD_VICENGINE_FILE=vic_10000.tar.gz               # File in `packer/scripts`
export BUILD_VICENGINE_URL=https://example.com/vic.tar.gz  # URL to download
```

Pick one to set Harbor version:

```
export BUILD_HARBOR_REVISION=v1.1.1                     # Defaults to dev (https://console.cloud.google.com/storage/browser/harbor-builds)
export BUILD_HARBOR_FILE=harbor-offline-installer.tgz   # File in `packer/scripts`
export BUILD_HARBOR_URL=https://example.com/harbor.tgz  # URL to download
```

Set the Admiral tag appended to `vic_`:

```
export BUILD_ADMIRAL_REVISION=v1.1.1  # defaults to `dev` to specify `vic_dev` tag (https://hub.docker.com/r/vmware/admiral/tags/)
```

Then set the required env vars for the build environment and make the release:
```
make ova
```


#### Upload

There are two additional make targets, `ova-build` and `ova-release`, that will upload the ova
to the appropriate google storage bucket upon successful build. You can invoke them by using the `step`
variable in build.sh, i.e. `./build/build.sh --step ova-release`

## Deploy

The OVA must be deployed to a vCenter.
Deploying to ESX host is not supported.

The recommended method for deploying the OVA:
- Access the vCenter Web UI, click `vCenter Web Client (Flash)`
- Right click on the desired cluster or resource pool
- Click `Deploy OVF Template`
- Select the URL or file and follow the prompts
- Power on the deployed VM
- Access the `Getting Started Page` by going to `https://<appliance_ip>:9443`

Alternative, deploying with `ovftool`:
```
export VC_USER="<your vCenter user>"
export VC_PASSWORD="<your vCenter password>"
export VC_IP="<your vCenter IP address>"
export VC_COMPUTE="<your vCenter compute resource>"
docker run -it --net=host -v $GOPATH/src/github.com/vmware/vic-product/installer/bin:/test-bin \
  gcr.io/eminent-nation-87317/vic-integration-test:1.34 ovftool --acceptAllEulas --X:injectOvfEnv \
  --X:enableHiddenProperties -st=OVA --powerOn --noSSLVerify=true -ds=datastore1 -dm=thin \
  --net:Network="VM Network" \
  --prop:appliance.root_pwd="password" \
  --prop:appliance.permit_root_login=True \
  --prop:management_portal.port=8282 \
  --prop:registry.port=443 \
  /test-bin/$(ls -1t bin | grep "\.ova") \
  vi://$VC_USER:$VC_PASSWORD@$VC_IP/$VC_COMPUTE
```

## Vendor

To build the installer dependencies, ensure `GOPATH` is set, then issue the following.
``
$ make gvt vendor
``

This will install the [gvt](https://github.com/FiloSottile/gvt) utility and retrieve the build dependencies via `gvt restore`


## Troubleshooting

#### Building the OVA outside of the CI workflow
``` 
Get the ova_secrets.yml file from vic-internal repo.
Cd to the the vic-product repo path on your Ubuntu VM.
Start a ovpn connection to the OVH network by running sudo openvpn ovpnconfigfile(.ovpn)
Set the drone timeout values as desired using the --timeout options in drone.
Use Drone exec to kickoff the OVA build.

drone exec --timeout "1h0m0s" --timeout.inactivity "1h0m0s" --repo.trusted --secrets-file "ova_secrets.yml" .drone.local.yml
```

