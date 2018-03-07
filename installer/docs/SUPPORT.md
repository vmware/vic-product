# VIC Appliance Troubleshooting Guide

This guide will help you to diagnose common issues with VIC appliance deployment and operation and
determine what information to collect for further debugging.

## General Support Information

This information about the environment and events that occurred leading to the failure *should be
included in every support request to assist in debugging*. 

_Basic Information_

REQUIRED:

- vCenter Server version:
- Embedded or external PSC:
- Filename of the OVA you deployed:
- Does the VIC appliance recieve configuration by DHCP?
- What [stage of the Appliance Lifecycle](#appliance-lifecycle) is the VIC appliance in?
- Attach the [VIC appliance support bundle](#appliance-support-bundle)

OPTIONAL, but helpful:

- IP address of VIC appliance:
- Hostname of VIC appliance:
- IP address of vCenter Server:
- Hostname of vCenter Server

_Detailed Information_

- What operation was being performed when the failure was noticed?
- Provide information from the `Support Information` section of the appropriate [Appliance Lifecycle
stage](#appliance-lifecycle)
- Provide additional detail as necessary


### Appliance Support Bundle

If you are using VIC appliance version 1.3.1 or greater and are able to SSH into the appliance,
please run `/etc/vmware/support/appliance-support.sh` and provide the resulting file to support.
This script gathers appliance state and log information and is the best tool for gathering
comprehensive support information. Provide this output for all support requests along with the
_Support Information_ from the corresponding stage of the Appliance Lifecycle.

The location of the resulting log bundle is shown in the script output, similar to this example:

```
Created log bundle /storage/log/vic_appliance_logs_2018-01-01-00-01-00.tar.gz
```

Provide this `.tar.gz` file to support.


## Appliance Lifecycle

It is important to determine what stage in the appliance lifecycle you are at when encountering
issues so that targeted troubleshooting steps can be followed. Please use the following names to
describe what stage the failure is in, to apply the appropriate troubleshooting steps, and to
provide the appropriate troubleshooting information to support.

### Deployment Stage

Deployment involves deploying the VIC appliance OVA using either the Flash/Flex client or `ovftool`.
The HTML5 client is not supported at this time.

During Deployment, the user provides customizations such as configuring the root password and other
optional configurations such as providing TLS certificates. If the version is 1.3.1 or less, TLS
certificates must be provided in a specific format [Certificate Reference](#additional-information).
Errors related to this will not appear until the Boot or Running Stage.

#### Deployment Failures

We have not experienced many failures during Deployment. If any issues occur, provide the Support
Information from below.

##### Support Information

Provide the following information to support if encountering Deployment failures:

- Hash (MD5, SHA-1, or SHA-256) of the OVA you deployed
- Deployment method:
    - Flash/Flex client
        - Screenshot of the failure screen
        - Copy paste the failed Task details
        - Copy paste any other error messages
    - `ovftool`
        - The entire `ovftool` command executed to deploy
        - Copy paste the failed Task details if present
        - Copy paste any error messages
- Deployment environment
    - Verify that the targeted datastore has enough space
    - Provide details about the targeted vCenter compute, storage, and networking


### Boot Stage

After the VIC appliance is deployed, it is powered on and boots. During this time the appliance
applies user provided configuration, starts an SSH server, and starts certain services. Soon after
the network interface comes up, SSH will become available on the appliance and a server on port 80
will display a message that appliance services are starting. In version 1.3.0, there may be a
significant delay before the web page is available on port 80. In version 1.3.1, a message will be
displayed while appliance services are starting, but you must refresh the page periodically until
the Getting Started Page is displayed when the appliance is ready.

#### Boot Failures

Failures during the operating system boot are rare. The most common boot failure involves changes to
attached hard disks, especially during upgrade operations. Failures that occur after the OS is
booted but before the Initialization Stage are usually related to user customizations.

##### Support Information

Provide the following information to support if encountering Boot failures:

- Is this a fresh deploy of the VIC appliance or an upgrade?
    - If upgrading, what version is the old VIC appliance?
- Were any changes made to the disk configuration of the VIC appliance?
    - If yes, what changes?
- Are you able to SSH into the VIC appliance?
    - If the version is 1.3.1 or greater and able to SSH, please run
      `/etc/vmware/support/appliance-support.sh` and provide the resulting file to support
    - If the version is 1.3.0 or less and able to SSH
        - Run `journalctl -u fileserver`and provide the entire resulting output to support
    - If the version is 1.3.0
        - Run `systemctl status vic-appliance-load-docker-images.service`
            - If this unit is still in progress, system required images are being loaded. Continue
              waiting until this unit is finished.
- Are you able to view the web page at http://<appliance_ip or FQDN>?
    - If no, did you provide custom TLS certificates during the Deployment Stage?
        - If yes and the version is 1.3.1 or less, verify the format is correct [Certificate
          Reference](#additional-information)
        - Run `journalctl -u fileserver`and provide the entire resulting output to support


### Initialization Stage

Reaching the Initialization Stage means that you can successfully view the Getting Started page at
http://<appliance_ip or FQDN>. The VIC appliance is ready to accept initialization information.

Initializing the VIC appliance means providing the appliance with the vCenter IP/hostname, vSphere
Administrator credentials, and PSC information if using an external PSC. This can be done through
either the Getting Started Page or the a HTTP request.

After a successful initialization on the Getting Started Page, a green bar showing a success message
will appear at the top of the Getting Started Page.

If the initialization was not successful, a red bar will appear at the top of the Getting Started
Page. If the page is reloaded, this bar will disappear, but it _does not_ mean that the appliance
has been successfully initialized.

After credentials are provided, the VIC appliance registers with the specified vCenter,
authenticates with the specified PSC to obtain authentication tokens, and starts Admiral and Harbor.

#### Initialization Failures

Failures during initialization are most often related to PSC authentication and networking. It is
important to determine whether PSC registration was successfully completed.

##### Support Information

Provide the following information to support if encountering Initialization failures:

- Are you able to view the web page at http://<appliance_ip or FQDN>?
    - If yes, after providing initialization information, did you see a green bar showing a success
      message?
        - If yes, appliance is initialized
        - If no, what error message was displayed in the red bar?
            - If the error is `Failed to register with PSC. Please check the PSC settings provided
              and try again.`
                - Verify PSC settings and use the `Re-initialize` button to try again
                - Check for clock skew between the VIC appliance and the PSC you have provided
            - Provide the error message to support and continue with SSH based steps below
    - If no:
        - Verify that the client has a route to the VIC appliance and is not blocked by network
          policy or architecture
        - If there are TLS handshake errors, check for clock skew between the client and VIC
          appliance and check that you are using a browser that supports modern TLS ciphers
    - If you are using VIC appliance version 1.4.0 or greater:
        - Did you provide custom TLS certificates?
            - If yes, does the VM console show the correct SHA1 fingerprint for the provided
              certificate?
                  - If no, check the formatting and that the correct values were provided in the
                    appropriate fields. If correct values were provided, continue with SSH based
                    steps below
    - If no, continue with SSH based steps below
- Did you attempt to initialize the VIC appliance by entering information in the Getting Started
  page?
    - If yes:
        -  Did you see a green bar at the top of the Getting Started Page?
            - If yes, continue with SSH based steps below
            - If no, initialization has not been completed. If repeated attempts do not display a
              green bar, continue with SSH based steps below
    - If no:
        - Enter the appropriate information as prompted
        - Ensure that a green bar showing a success message appears at the top of the Getting
          Started Page
- Did you attempt to initialize the VIC appliance by using the initialization API?
    - If yes:
        - Provide the entire `curl` command attempted
        - Provide the response received when executing the command
- Are you able to SSH into the VIC appliance?
    - If you are using VIC appliance version 1.3.1 or greater and are able to SSH into the
      appliance, please run `/etc/vmware/support/appliance-support.sh` and provide the resulting
      file to support.
    - If using VIC appliance version 1.2.1 or 1.3.0:
        - Run `journalctl -u fileserver`and provide the entire resulting output to support
    - Run `systemctl status fileserver`
        - If the unit shows "Running" and you are not able to view the webserver in your browser:
            - Check the network configuration between the VIC appliance and the client:
                - Is the client or VIC appliance using a 172.16.0.0/16 IP address?
                  (https://github.com/vmware/vic-product/issues/667)
            - Check `journalctl -u fileserver`
                - You should see webserver logs from your client's requests to the Getting Started
                  Page
                - If there are TLS handshake errors, check for clock skew between the client and VIC
                  appliance and verify that you are using a browser that supports modern TLS ciphers
- If there are PSC registration errors, follow [Admiral Troubleshooting
  Guide](https://github.com/vmware/admiral/wiki/Troubleshooting-VIC)


### Running Stage

Reaching the Running Stage means that the VIC appliance was successfully initialized and received a
green bar at the top of the Getting Started Page. Admiral and Harbor will start shortly after the
green bar is completed and the user can follow links on the Getting Started Page to access the
Admiral web interface.

Once the VIC appliance shows that initialization has succeeded and that Admiral and Harbor are
started, troubleshooting must move to the application.

#### Running Failures

If you have forgotten the root password to the VIC appliance and the version is 1.3.1 or greater,
follow these [instructions to reset the
password](https://github.com/vmware/photon/blob/master/docs/photon-os-troubleshooting-guide.md#resetting-a-lost-root-password).
If the version is less than 1.3.1, it may not be possible to recover the password due to a short
GRUB timeout.

Failures during running that are related to Admiral and Harbor functionality are outside the scope
of Running Failures. After verifying that Admiral and Harbor services are running, proceed with
[application specific troubleshooting](#application-specific-troubleshooting).

##### Support Information

Provide the following information to support if encountering Initialization failures:

- Are Admiral and Harbor running?
    - Run `systemctl status admiral`
    - Run `journalctl -u admiral` and provide the entire resulting output to support
    - Run `systemctl status harbor`
    - Run `journalctl -u harbor` and provide the entire resulting output to support
    - If the version is 1.3.1 or less, run `journalctl -u admiral_startup` and provide the entire
      resulting output to support
    - If the version is 1.3.1 or less, run `journalctl -u harbor_startup` and provide the entire
      resulting output to support
- If Admiral is not running and `systemctl status get_token` shows that the service failed, check
  `journalctl -u get_token`
    - If the logs show errors obtaining tokens and mentioning clock skew, there may be clock skew
      between the appliance and the PSC
        - The appliance recieves NTP configuration from DHCP by default. If DHCP is not used, set
          time synchronization by one of these two methods:
            - Set "Synchronize guest time with host" in vSphere, shutdown guest OS, and power on to
              apply the setting (not restart/reboot)
              [https://kb.vmware.com/s/article/1014038](https://kb.vmware.com/s/article/1014038)
            - SSH into the appliance and configure NTP by `timedatectl set-ntp true`. NTP servers
              can be customized in `/etc/systemd/timesyncd.conf`.
- If the Admiral web interface shows an error `SsoManager has not been initialized at runtime`, see
  [Admiral Troubleshooting Guide](https://github.com/vmware/admiral/wiki/Troubleshooting-VIC).
- If Admiral is not running, did you provide custom TLS certificates during the Deployment Stage?
    - If yes, verify the format is correct [Certificate Reference](#additional-information)
        - Run `journalctl -u admiral`and provide the entire resulting output to support
        - If the version is 1.3.1 or less, run `journalctl -u admiral_startup` and provide the
          entire resulting output to support


### UI Plugin Installation Stage

TODO

#### UI Plugin Installation Failures

TODO

##### Support Information

TODO


### Appliance Upgrade Stage

Users may upgrade to a new version of the VIC appliance. Only certain upgrade paths are valid.

#### Appliance Upgrade Failures

Upgrade failures may result from failing to move the disks correctly or failures with upgrading
services that run on the VIC appliance.

##### Support Information

- What is the old version of the VIC appliance?
    - Run `cat /etc/vmware/version` on the old appliance and provide the entire resulting output to
      support
- What is the new version of the VIC appliance?
    - Run `cat /etc/vmware/version` on the old appliance and provide the entire resulting output to
      support
- Were the hard disks from the old appliance moved properly to the new appliance?
    - Follow the official documentation to move and verify that the disks are attached to the
      correct Virtual Device Node
- Was the appliance upgrade script run?
    - If yes, collect `/var/log/vmware/upgrade.log` and provide to support
    - If no, run the upgrade script following the official documentation
- Was the new appliance initialized before running the appliance upgrade script?
    - If yes, this is not the proper upgrade procedure and may have undefined results. Redeploy the
      new VIC appliance and follow the proper upgrade procedure according to the official
      documentation


### UI Plugin Upgrade Stage

TODO

#### UI Plugin Upgrade Failures

TODO

##### Support Information

TODO


### Application Specific Troubleshooting

Several applications, also referred to as components, run on the VIC appliance. These include Harbor
and Admiral. If you are having trouble with a specific component, but have verified that it is
running based on steps in the [Running Stage](#running-stage), follow the below steps to
troubleshoot and collect information about the specific component.

#### Admiral

TODO Add information about general failures that may occur

##### Support Information

TODO Add steps to troubleshoot and gather required information for debugging if unable to resolve an
issue

#### Harbor

If user sees issues in below areas, there are likely some errors in Harbor components:
 - Unable to list repositories on UI (Home > Library > Project repositories).
 - Errors in image scan/replication. 
 - Unexpected error in `docker pull` or `docker push`
 - Failed to deploy containers and the error happens when pulling the image.

##### Support Information

 - Check the status of Harbor's containers: Run `docker ps` on the appliance VM, and make sure the follow containers are running: `nginx`, `harbor-jobservice`, `harbor-ui`, `harbor-adminserver`, `harbor-log`, `harbor-db`, `notary-signer`, `notary-server`, `notary-db`, `clair`, `clair-db`.

 - Log collection: The log files are stored in the directory `/storage/log/harbor` of the appliance. 
As for scan/replication failure, please also check the job logs from UI page where the scan/replication actions are triggered.

## Additional Information

- [VIC Appliance Design
  Document](https://github.com/vmware/vic-product/blob/master/installer/docs/DESIGN.md)
- [VIC Appliance Certificate
  Reference](https://vmware.github.io/vic-product/assets/files/html/1.3/vic_vsphere_admin/vic_cert_reference.html)
