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

###### Versioning Components

The build script pulls the desired versions of each included component into the build container.
It accepts files in the `installer/build` directory, URLs, or revisions and automatically sets
required environment variables.

*You must specify build step `ova-dev` when calling build.sh*

If called without any values, `build.sh` will get the latest build for each component
```
sudo ./build/build.sh ova-dev
```

Default values:
```
--admiral dev <vmware/admiral:vic_dev tag>
--harbor <latest in harbor-builds bucket>
--vicengine <latest in vic-engine-builds bucket>
--vicmachineserver dev <vic-machine-server:dev tag>
--vicui <latest in vic-ui-builds bucket>

DCH Photon is pinned to 1.13 tag
```

If called with the values below, `build.sh` will include the Harbor version from
`installer/build/harbor.tgz`, the VIC Engine version from `installer/build/vic_XXXX.tar.gz`, and 
Admiral tag `vic_dev` (since `--admiral` was not specified it defaults to the `vic_dev` tag)
```
./build/build.sh ova-dev --harbor harbor.tgz --vicengine vic_XXXX.tar.gz
```

If called with the values below, `build.sh` will include the Harbor, VIC Engine and VIC UI versions
specified by their respective URLs, Admiral tag `vic_v1.1.1`, and VIC Machine Server tag `latest`.
```
./build/build.sh ova-dev --admiral v1.1.1 --harbor https://example.com/harbor.tgz --vicengine https://example.com/vic_XXXX.tar.gz --vicui https://example.com/vic_ui_XXXX.tar.gz --vicmachineserver latest
```

Note: the VIC Engine artifact used when building the OVA must be named following the `vic_*.tar.gz` format.

###### Build Script Flow

The VIC Appliance Builder is made up of three bash scripts `installer/build/build.sh`, `installer/build/build-ova.sh`, and `installer/build/build-cache.sh`. These three scripts set up the necessary environment variables needed to build VIC, download and make the component dependencies, and kick off the bootable build in a docker container. 

The `bootable` folder contains all the files needed to make a bootable ova. These include `build-main.sh`, which organizes the calls for `build-disks.sh`, `build-base.sh`, and `build-app.sh`. 

These three scripts are self-explanatory:
 - `build-disks.sh`: Provisions local disk space for the boot and data drives. Installs grub2 to the boot drive.
 - `build-base.sh`: Installs all repo components, like a linux kernel and coreutils, to the base disks. Can be cached as a gzipped tar.
 - `build-app.sh`: Performs any necessary configuration of the ova by running all script provisioners in a chroot.

The `bootable` folder also contains ovf template and tdnf repos for building the ova.

There are many useful arguments for `build-main.sh`, but most notable is the `-b` argument for caching the base layer for faster builds. This option can be passed throught the first `build.sh` script, like `./build/build.sh ova-dev -b bin/.vic-appliance-base.tar.gz`.

The general order of execution is `build.sh` -> `build-ova.sh`  -> `build-cache.sh` -> `bootable/build-main.sh` -> `bootable/build-disks.sh` -> `bootable/build-base.sh` -> `bootable/build-app.sh` -> ova export.

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
  --prop:management_portal.management_portal_port=8282 \
  --prop:registry.registry_port=443 \
  /test-bin/$(ls -1t bin | grep "\.ova") \
  vi://$VC_USER:$VC_PASSWORD@$VC_IP/$VC_COMPUTE
```

## Vendor

To build the installer dependencies, ensure `GOPATH` is set, then issue the following.
``
$ make vendor
``

This will install the [dep](https://github.com/golang/dep) utility and retrieve the build dependencies via `dep ensure`.

NOTE: Dep is slow the first time you run it - it may take 10+ minutes to download all of the dependencies. This is because
dep automatically falttens the vendor folders of all dependencies. In most cases, you shouldn't need to run `make vendor`,
as our vendor directory is checked in to git.

## CI Workflow

VIC Product build is auto-triggered from the successful completion of the following CI builds:

[VIC Engine](https://ci-vic.vmware.com/vmware/vic)

[Admiral](https://ci-vic.vmware.com/vmware/admiral)

[Harbor](https://ci-vic.vmware.com/vmware/harbor)

There is also a separate build for [VIC UI](https://ci-vic.vmware.com/vmware/vic-ui) which publishes the [artifact](https://console.cloud.google.com/storage/browser/vic-ui-builds) consumed by VIC Product builds. VIC Engine publishes vic engine artifacts and vic machine server image.
Harbor build publishes harbor installer and Admiral build publishes admiral image. All these artifacts are published to Google cloud except Admiral image which is published to Docker hub.

### Dependency Relationship

The version of each dependency VIC Product consumes varies based on the type of build being performed.

| Admiral                 | `master`                                                | `releases/*`                                                   |
| -----------------------:| ------------------------------------------------------- | -------------------------------------------------------------- |
|`pull_request`           | [image][a] tagged with `vic_dev`                        | [image][a] tagged with `vic_dev`                               |
|`push`                   | [image][a] tagged with `vic_dev`                        | [image][a] tagged with `vic_dev`                               |
|`tag` (containing `dev`) | [image][a] tagged with `vic_dev`                        | [image][a] tagged with `vic_dev`                               |
|`tag` (other)            | latest [image][a] that has a tag beginning with `vic_v` | latest [image][a] that has a tag beginning with `vic_v`        |
|`deployment`             | manually specified                                      | manually specified                                             |

| Harbor                  | `master`                                                | `releases/*`                                                   |
| -----------------------:| ------------------------------------------------------- | -------------------------------------------------------------- |
|`pull_request`           | the build from [`harbor-builds/master.stable`][hb]      | latest build published to [`harbor-releases`][hr]              |
|`push`                   | the build from [`harbor-builds/master.stable`][hb]      | latest build published to [`harbor-releases`][hr]              |
|`tag` (containing `dev`) | the build from [`harbor-builds/master.stable`][hb]      | latest build published to [`harbor-releases`][hr]              |
|`tag` (other)            | latest build published to [`harbor-releases`][hr]       | latest build published to [`harbor-releases`][hr]              |
|`deployment`             | manually specified                                      | manually specified                                             |

| Engine                  | `master`                                                | `releases/*`                                                   |
| -----------------------:| ------------------------------------------------------- | -------------------------------------------------------------- |
|`pull_request`           | latest build published to [`vic-engine-builds`][vb]     | latest build published to [`vic-engine-builds/releases/*`][vb] |
|`push`                   | latest build published to [`vic-engine-builds`][vb]     | latest build published to [`vic-engine-builds/releases/*`][vb] |
|`tag` (containing `dev`) | latest build published to [`vic-engine-builds`][vb]     | latest build published to [`vic-engine-builds/releases/*`][vb] |
|`tag` (other)            | latest build published to [`vic-engine-releases`][vr]   | latest build published to [`vic-engine-releases`][vr]          |
|`deployment`             | manually specified                                      | manually specified                                             |

| vic-ui                  | `master`                                                | `releases/*`                                                   |
| -----------------------:| ------------------------------------------------------- | -------------------------------------------------------------- |
|`pull_request`           | latest build published to [`vic-ui-builds`][vb]         | latest build published to [`vic-ui-builds/releases/*`][vb]     |
|`push`                   | latest build published to [`vic-ui-builds`][vb]         | latest build published to [`vic-ui-builds/releases/*`][vb]     |
|`tag` (containing `dev`) | latest build published to [`vic-ui-builds`][vb]         | latest build published to [`vic-ui-builds/releases/*`][vb]     |
|`tag` (other)            | latest build published to [`vic-ui-releases`][vr]       | latest build published to [`vic-ui-releases`][vr]              |
|`deployment`             | manually specified                                      | manually specified                                             |

| `vic-machine-server`    | `master`                                                | `releases/*`                                                   |
| -----------------------:| ------------------------------------------------------- | -------------------------------------------------------------- |
|`pull_request`           | [image][vms] tagged with `dev`                          | latest [image][vms] tagged with the release's version number   |
|`push`                   | [image][vms] tagged with `dev`                          | latest [image][vms] tagged with the release's version number   |
|`tag` (containing `dev`) | [image][vms] tagged with `dev`                          | latest [image][vms] tagged with the release's version number   |
|`tag` (other)            | latest [image][vms] tagged with a version number        | latest [image][vms] tagged with a version number               |
|`deployment`             | manually specified                                      | manually specified                                             |

[a]:https://hub.docker.com/r/vmware/admiral/
[hb]:https://storage.googleapis.com/harbor-builds
[hr]:https://storage.googleapis.com/harbor-releases
[vb]:https://storage.googleapis.com/vic-engine-builds
[vr]:https://storage.googleapis.com/vic-engine-releases
[vms]:https://console.cloud.google.com/gcr/images/eminent-nation-87317/GLOBAL/vic-machine-server?project=eminent-nation-87317&gcrImageListsize=50

The OVA artifact is published to:
 * [`vic-product-ova-builds`](https://storage.googleapis.com/vic-product-ova-builds) after successful build and test following `push` to `master`
 * [`vic-product-ova-builds/releases/*`](https://storage.googleapis.com/vic-product-ova-builds) after successful build and test following `push` to `releases/*`
 * [`vic-product-ova-builds`](https://storage.googleapis.com/vic-product-ova-builds) after successful build and test following creation of a `tag`
 * [`vic-product-ova-builds`](https://storage.googleapis.com/vic-product-ova-builds) after successful build and test following `deployment` to `staging`
 * [`vic-product-ova-releases`](https://storage.googleapis.com/vic-product-ova-releases) after successful build and test following `deployment` to `release`
 * [`vic-product-failed-builds`](https://storage.googleapis.com/vic-product-failed-builds) after a failure building or testing

Refer to the next section `Staging and Release` on how to build OVA with specific dependent component versions ("manually specified").

## Staging and Release

To perform staging and release process using Drone CI, refer to following commands. 
Please note that you cannot trigger new CI builds manually, but have to promote existing build to either staging or release.

Make sure `DRONE_SERVER` and `DRONE_TOKEN` environment variables are set before executing these commands.

To promote existing successful CI build to staging (`vic-product-ova-builds` bucket), `drone deploy` to `staging` using the command output at the end of the `unified-ova-build` step of the `tag` build. This output will look like:

```
drone deploy --param VICENGINE=<vic_engine_version> \
             --param VIC_MACHINE_SERVER=<vic_machine_server> \
             --param ADMIRAL=<admiral_tag> \
             --param HARBOR=<harbor_version> \
             --param VICUI=<vic_ui_version> \
             vmware/vic-product <ci_build_number_to_promote> staging
```

To promote existing successful CI build to release (`vic-product-ova-releases` bucket), `drone deploy` to `release` using the command output at the end of the `unified-ova-build` step of the `staging` build. This output will look like:

```
drone deploy --param VICENGINE=<vic_engine_version> \
             --param VIC_MACHINE_SERVER=<vic_machine_server> \
             --param ADMIRAL=<admiral_tag> \
             --param HARBOR=<harbor_version> \
             --param VICUI=<vic_ui_version> \
             vmware/vic-product <ci_build_number_to_promote> release
```

Example:

```
drone deploy --param VICENGINE=https://storage.googleapis.com/vic-engine-releases/vic_v1.4.0.tar.gz \
             --param VIC_MACHINE_SERVER=latest \
             --param ADMIRAL=v1.4.0 \
             --param HARBOR=https://storage.googleapis.com/harbor-releases/harbor-offline-installer-v1.5.0.tgz \
             --param VICUI=https://storage.googleapis.com/vic-ui-releases/vic_ui_v1.4.0.tar.gz \
             vmware/vic-product <ci_build_number_to_promote> release
```

All variables are populated with the values which were used by the build being promoted to the next step of the process. This provides you an opportunity to review the included components and ensures that new versions of components are not inadvertently introduced between steps of this process due to automatic component selection logic.
