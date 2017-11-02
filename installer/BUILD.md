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
It accepts files in the `installer/build` directory, URLs, or revisions and automatically sets
required environment variables.

*You must specify build step `ova-dev` when calling build.sh*

If called without any values, `build.sh` will get the latest build for each component
```
sudo ./build/build.sh ova-dev
```

If called with the values below, `build.sh` will include the Harbor version from
`installer/build/harbor.tgz`, the VIC Engine version from `installer/build/vic.tar.gz`, and 
Admiral tag `vic_dev` (since `--admiral` was not specified it defaults to the `vic_dev` tag)
```
./build/build.sh ova-dev --harbor harbor.tgz --vicengine vic.tar.gz
```

If called with the values below, `build.sh` will include the Harbor and VIC Engine versions
specified by their respective URLs, and Admiral tag `vic_v1.1.1`
```
./build/build.sh ova-dev --admiral v1.1.1 --harbor https://example.com/harbor.tgz --vicengine https://example.com/vic.tar.gz
```

#### Upload

You can upload the ova builds to the `vic-product-ova-builds` and `vic-product-ova-releases` in google cloud.

*Personal development builds MUST be renamed with the username as a prefix before upload*

To do this, use the gsutil cli tool: `sudo gsutil cp -va public-read johndoe-vic-v1.2.1.ova gs://vic-product-ova-builds`.

## Deploy

The OVA must be deployed to a vCenter.
Deploying to ESX host is NOT supported.

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


## Staging and Release
To perform staging and release process using Drone CI, refer to following commands. 
Please note that you cannot trigger new CI builds manually, but have to promote existing build to either staging or release.

Make sure `DRONE_SERVER` and `DRONE_TOKEN` environment variables are set before executing these commands.

To promote existing successful CI build to staging...
``
$ drone deploy --param VICENGINE=<vic_engine_version> --param VIC_MACHINE_SERVER=<vic_machine_server> --param ADMIRAL=<admiral_tag> --param HARBOR=<harbor_version> vmware/vic-product <ci_build_number_to_promote> staging
``

To promote existing successful CI build to release...
``
$ drone deploy --param VICENGINE=<vic_engine_version> --param VIC_MACHINE_SERVER=<vic_machine_server> --param ADMIRAL=<admiral_tag> --param HARBOR=<harbor_version> vmware/vic-product <ci_build_number_to_promote> release
``

`vic_engine_version` and `harbor_version` can be specified as a URL or a file in `cwd`, eg. 'https://storage.googleapis.com/vic-engine-releases/vic_1.2.1.tar.gz'

`admiral_tag` and `vic_machine_server` should be specified as docker image revision tag, eg. 'latest'

`ci_build_number_to_promote` is the drone build number which will be promoted


## Troubleshooting

#### Building the OVA outside of the CI workflow
``` 
Use Drone exec to kickoff the OVA build.

drone exec --timeout "1h0m0s" --timeout.inactivity "1h0m0s" --repo.trusted .drone.local.yml
```
