# VIC Unified Installer

This directory will host all the code that is going to be part of the VIC unified installer OVA.

It is currently under heavy development and not suitable for any use except for development, this file will be updated to reflect the status of the installer as development progresses.

## Usage

```
esxcli system settings advanced set -o /Net/GuestIPHack -i 1
esxcli network firewall set --enabled false
```

The machine that is running Packer (make ova-release) must be reachable from the launched VM and
have `ovftool` installed

### Build bundle and OVA

#### Build script

The build script accepts files in `packer/scripts`, URLs, or revisions and automatically sets
required environment variables. `BUILD_VICENGINE_REVISION` is required for UI plugin even if using
file or URL.

Export required values
```
export PACKER_ESX_HOST=1.1.1.1
export PACKER_USER=root
export PACKER_PASSWORD=password
```

If called without any values, `build.sh` will get the latest build for each component
```
export BUILD_VICENGINE_REVISION=1.1.1
./scripts/build.sh
```

Build with files `packer/scripts/harbor.tgz` and `packer/scripts/vic.tar.gz` and Admiral tag
`vic_dev`.
```
export BUILD_VICENGINE_REVISION=1.1.1
./scripts/build.sh --harbor harbor.tgz --vicengine vic.tar.gz
```

Build with URLs, Admiral tag v1.1.1 and Kov(including kovd and kov-cli) tag v0.1
```
export BUILD_VICENGINE_REVISION=1.1.1
./scripts/build.sh --admiral v1.1.1 --kovd v0.1 --kov-cli v0.1 --harbor https://example.com/harbor.tgz --vicengine https://example.com/vic.tar.gz
```

#### Manual

First, we have to set the revisions of the components we want to bundle in the OVA.
Specifying a file takes precedence, then URL, then revision.

```
export BUILD_VICENGINE_REVISION=1.1.1                      # Required (https://console.cloud.google.com/storage/browser/vic-engine-releases)
                                                           # If specifying file or URL, REVISION is used for setting UI plugin version
export BUILD_VICENGINE_FILE=vic_10000.tar.gz               # Optional, file in `packer/scripts` export
export BUILD_VICENGINE_URL=https://example.com/vic.tar.gz  # Optional, URL to download

export BUILD_HARBOR_REVISION=v1.1.1                     # Optional, defaults to dev (https://console.cloud.google.com/storage/browser/harbor-builds)
export BUILD_HARBOR_FILE=harbor-offline-installer.tgz   # Optional, file in `packer/scripts`
export BUILD_HARBOR_URL=https://example.com/harbor.tgz  # Optional, URL to download

export BUILD_ADMIRAL_REVISION=v1.1.1  # Optional, defaults to vic_dev tag (https://hub.docker.com/r/vmware/admiral/tags/)

export BUILD_KOVD_REVISION=v0.1 # Optional, defaults to dev tag
export BUILD_KOV_CLI_REVISION=v0.1 # Optional, defaults to dev tag
```

Then set the required env vars for the build environment and make the release:

```
export PACKER_ESX_HOST=1.1.1.1
export PACKER_USER=root
export PACKER_PASSWORD=password
export PACKER_LOG=1  # Optional

make ova-release
```

Deploy OVA with ovftool in a Docker container on ESX host
```
docker run -it --net=host -v ~/go/src/github.com/vmware/vic/bin:/test-bin \
  gcr.io/eminent-nation-87317/vic-integration-test:1.29 ovftool --acceptAllEulas --X:injectOvfEnv \
  --X:enableHiddenProperties -st=OVA --powerOn --noSSLVerify=true -ds=datastore1 -dm=thin \
  --net:Network="VM Network" \
  --prop:appliance.root_pwd="VMware1\!" --prop:appliance.permit_root_login=True --prop:registry.port=443 \
  --prop:management_portal.port=8282 --prop:registry.admin_password="VMware1\!" \
  --prop:registry.db_password="VMware1\!" /test-bin/vic-1.1.0-a84985b.ova \
  vi://root:password@192.168.1.20
```

## Vendor

To build the installer dependencies, ensure `GOPATH` is set, then issue the following.
``
$ make gvt vendor
``

This will install the [gvt](https://github.com/FiloSottile/gvt) utility and retrieve the build dependencies via `gvt restore`


## Troubleshooting

### ova-release failed

```
2017/03/16 10:26:25 packer: 2017/03/16 10:26:25 starting remote command: test -e
/vmfs/volumes/datastore1/vic
2017/03/16 10:26:25 ui error: ==> ova-release: Step "StepOutputDir" failed, aborting...
==> ova-release: Step "StepOutputDir" failed, aborting...
Build 'ova-release' errored: unexpected EOF

==> Some builds didn't complete successfully and had errors:
2017/03/16 10:26:25 ui error: Build 'ova-release' errored: unexpected EOF
2017/03/16 10:26:25 Builds completed. Waiting on interrupt barrier...
2017/03/16 10:26:25 machine readable: error-count []string{"1"}
2017/03/16 10:26:25 ui error:
==> Some builds didn't complete successfully and had errors:
2017/03/16 10:26:25 machine readable: ova-release,error []string{"unexpected EOF"}
2017/03/16 10:26:25 ui error: --> ova-release: unexpected EOF
2017/03/16 10:26:25 ui:
==> Builds finished but no artifacts were created.
2017/03/16 10:26:25 waiting for all plugin processes to complete...
2017/03/16 10:26:25 /usr/local/bin/packer: plugin process exited
2017/03/16 10:26:25 /usr/local/bin/packer: plugin process exited
2017/03/16 10:26:25 /usr/local/bin/packer: plugin process exited
2017/03/16 10:26:25 /usr/local/bin/packer: plugin process exited
--> ova-release: unexpected EOF

==> Builds finished but no artifacts were created.
2017/03/16 10:26:25 /usr/local/bin/packer: plugin process exited
installer/vic-unified-installer.mk:31: recipe for target 'ova-release' failed
make: *** [ova-release] Error 1
```

Solution: Cleanup datastore by removing the `vic` folder


#### Connection refused

```
2017/03/16 12:48:46 ui: ==> ova-release: Connecting to VM via VNC
==> ova-release: Connecting to VM via VNC
2017/03/16 12:49:13 ui error: ==> ova-release: Error connecting to VNC: dial tcp 10.17.109.107:5900:
getsockopt: connection refused
==> ova-release: Error connecting to VNC: dial tcp 10.17.109.107:5900: getsockopt: connection
refused
```

Solution: Disable firewall on ESX host `esxcli network firewall set --enabled false`

#### No IP address ready

```
2017/03/23 12:03:45 packer: 2017/03/23 12:03:45 opening new ssh session
2017/03/23 12:03:45 packer: 2017/03/23 12:03:45 starting remote command: esxcli --formatter csv
network vm list
2017/03/23 12:03:46 packer: 2017/03/23 12:03:46 opening new ssh session
2017/03/23 12:03:46 packer: 2017/03/23 12:03:46 starting remote command: esxcli --formatter csv
network vm port list -w 73094
2017/03/23 12:03:46 packer: 2017/03/23 12:03:46 [DEBUG] Error getting SSH address: No interface on
the VM has an IP address ready
```

Solution: Disable firewall on the build machine. The launched VM is unable to get the kickstart file
from your build machine.
