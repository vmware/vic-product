# VIC Product OVA Build

The build process (launched from your "build machine") uses Packer to launch a VM ("Packer VM") in
ESX, provision it with components, and snapshot it to make the OVA.

After the Packer VM is powered on, it attempts to retrieve a kickstart file from the build machine.
The Packer VM then boots based on the kickstart file. When the base Packer VM is booted, Packer uses
`packer-vic.json` to provision the Packer VM. This copies files to the Packer VM and runs scripts on
the Packer VM which download components included in the OVA (Admiral, Harbor, VIC Engine, DCH) to
the correct location and configures them if needed. After provisioning is complete, a snapshot of
the VM is taken to make the OVA.

## Usage

### Prerequisites

The Packer VM _MUST_ have a route to your build machine because the Packer VM boots from a
kickstart file served from the build machine. This means if the build machine and target ESX are run
in Fusion or Workstaion, both VMs should have either bridged or shared networking.

The build machine must have `ovftool` and if using `build.sh` must have `gsutil`.

- `gsutil`: https://cloud.google.com/sdk/downloads
- `ovftool`: https://www.vmware.com/support/developer/ovf/

Execute these commands on your ESX:
```
esxcli system settings advanced set -o /Net/GuestIPHack -i 1
esxcli network firewall set --enabled false
```

### Build bundle and OVA

#### Build script

This is the recommended way to build the OVA.

Export required values
```
export PACKER_ESX_HOST=1.1.1.1
export PACKER_USER=root
export PACKER_PASSWORD=password
```

The build script pulls the desired versions of each included component into the Packer VM.
It accepts files in `packer/scripts`, URLs, or revisions and automatically sets
required environment variables. `BUILD_VICENGINE_REVISION` is required for UI plugin even if using
file or URL.

If called without any values, `build.sh` will get the latest build for each component
```
export BUILD_VICENGINE_REVISION=1.1.1
./scripts/build.sh
```

If called with the values below, `build.sh` will include the Harbor version from
`packer/scripts/harbor.tgz`, the VIC Engine version from `packer/scripts/vic.tar.gz`, and Admiral tag
`vic_dev` (since `--admiral` was not specified it defaults to the `vic_dev` tag)
```
export BUILD_VICENGINE_REVISION=1.1.1
./scripts/build.sh --harbor harbor.tgz --vicengine vic.tar.gz
```

If called with the values below, `build.sh` will include the Harbor and VIC Engine versions
specified by their respective URLs, and Admiral tag `vic_v1.1.1`
```
export BUILD_VICENGINE_REVISION=1.1.1
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
export PACKER_ESX_HOST=1.1.1.1
export PACKER_USER=root
export PACKER_PASSWORD=password
export BUILD_PORTGROUP="VM Network" # Port group that Packer VM is connected to, defaults to "VM Network" in `build.sh`
export PACKER_LOG=1                 # Optional

make ova-release
```

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
docker run -it --net=host -v ~/go/src/github.com/vmware/vic-product/installer/bin:/test-bin \
  gcr.io/eminent-nation-87317/vic-integration-test:1.34 ovftool --acceptAllEulas --X:injectOvfEnv \
  --X:enableHiddenProperties -st=OVA --powerOn --noSSLVerify=true -ds=datastore1 -dm=thin \
  --net:Network="VM Network" \
  --prop:appliance.root_pwd="password" \
  --prop:appliance.permit_root_login=True \
  --prop:management_portal.port=8282 \
  --prop:registry.port=443 \
  --prop:cluster_manager.admin="Administrator" \
  /test-bin/vic-a2f93359.ova \
  vi://root:password@192.168.1.86
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

Solution: Disable firewall on the build machine and check networking. The Packer VM is unable to
get the kickstart file from your build machine.

#### Unable to find available VNC port between 5900 and 6000

With `export PACKER_LOG=1`, you can see following message
```
==> ova-release: Starting HTTP server on port 8098
2017/06/27 02:58:00 ui: ==> ova-release: Starting HTTP server on port 8098
2017/06/27 02:58:00 packer: 2017/06/27 02:58:00 Looking for available port between 5900 and 6000
2017/06/27 02:58:00 packer: 2017/06/27 02:58:00 opening new ssh session
2017/06/27 02:58:00 packer: 2017/06/27 02:58:00 starting remote command: esxcli --formatter csv network ip connection list
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address :::22, port 22 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address 0.0.0.0:22, port 22 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address fd01:0:101:2601:0:a:0:ca7:427, port 427 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address fd01:0:101:2601:0:17ff:febd:4c8c:427, port 427 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address fe80:2::17ff:febd:4c8c:427, port 427 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address x.x.x.x:427, port 427 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address 0.0.0.0:443, port 443 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address :::443, port 443 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address 0.0.0.0:80, port 80 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address :::80, port 80 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address :::9080, port 9080 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address :::8000, port 8000 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address :::902, port 902 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address 0.0.0.0:902, port 902 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 ESXi listening on address :::8300, port 8300 unavailable for VNC
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Trying address: x.x.x.x:5900...
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Timeout connecting to: x.x.x.x:5900 (check firewall rules)
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Trying address: x.x.x.x:5901...
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Timeout connecting to: x.x.x.x:5901 (check firewall rules)
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Trying address: x.x.x.x:5902...
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Timeout connecting to: x.x.x.x:5902 (check firewall rules)
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Trying address: x.x.x.x:5903...
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Timeout connecting to: x.x.x.x:5903 (check firewall rules)
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Trying address: x.x.x.x:5904...
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Timeout connecting to: x.x.x.x:5904 (check firewall rules)
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Trying address: x.x.x.x:5905...
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Timeout connecting to: x.x.x.x:5905 (check firewall rules)
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Trying address: x.x.x.x:5906...
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Timeout connecting to: x.x.x.x:5906 (check firewall rules)
2017/06/27 02:58:01 packer: 2017/06/27 02:58:01 Trying address: x.x.x.x:5907...
```

Solution: If firewall is disabled already, set a reasonable timeout for VNC port connection `export PACKER_ESXI_VNC_PROBE_TIMEOUT=30s` or even longer.

#### Waiting for SSH

```
==> ova-release: Waiting for SSH to become available...
```

Look at the console for the launched `vic` Packer VM. The Packer VM might not be able to get the
kickstart file to boot.

Solution: Check networking. The Packer VM must have a route to the build machine. You may also need to disable the firewall on the build machine:
```
sudo ufw disable
```

#### Building the OVA outside of the CI workflow
``` 
Get the ova_secrets.yml file from vic-internal repo.
Cd to the the vic-product repo path on your Ubuntu VM.
Start a ovpn connection to the OVH network by running sudo openvpn ovpnconfigfile(.ovpn)
Set the drone timeout values as desired using the --timeout options in drone.
Use Drone exec to kickoff the OVA build.

drone exec --timeout "1h0m0s" --timeout.inactivity "1h0m0s" --repo.trusted --secrets-file "ova_secrets.yml" .drone.local.yml
```

