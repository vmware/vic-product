# VIC Appliance Design

## Introduction

This document covers the design for the VIC Appliance and specifies the requirements for components
to be included in the VIC Appliance ("Appliance").

The current state of the Appliance may not be in full compliance with the design. These cases will
be noted in this document and updated once the issue is resolved.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in
[RFC 2119](https://tools.ietf.org/html/rfc2119).

## Design Principles

The OVA includes several components developed by various teams. Each component team is responsible
for the software quality of their component, for delivering the component artifacts, and for
managing upgrade functionality of the component within the guidelines of this document.

The component team will work with the Appliance team to manage the lifecycle of the process and
integrate the component with the Appliance.

The Appliance is based on [Photon OS](https://github.com/vmware/photon) and uses Systemd for process
management. Component processes are generally run as Docker containers.

### Requirements

- A normally functioning component SHOULD NOT contain error messages in its logs or system logs for
  its systemd unit

  During troubleshooting and testing, unnecessary error logs will cause confusion.

- A degraded component SHOULD display a user friendly error message through its primary UI

  Components should not silently exclude expected functionality and should notify users if the
  component is not functioning normally.

- A degraded component SHOULD log messages relevant to troubleshooting

  Components should not silently exclude expected functionality and should assist in determining the
  cause of failure.

- A failed component MUST exit cleanly or degrade to displaying a user friendly error message
  through its primary UI

  Failed components should not affect other unrelated processes still running on the Appliance.
  Components should not silently exclude expected functionality and should notify users if the
  component is not functioning normally.

- A failed component MUST exit with a nonzero exit code if it is unable to gracefully degrade

  Exiting in this manner will assist in identification of the failure during troubleshooting.


## Versioning

The version of each component MUST be recorded during the Appliance build and included in the
Appliance artifact in the file `/etc/vmware/version` and `/data/version`.

After a successful Appliance upgrade, the system version file MUST overwrite the previous data disk
version file to indicate that the data has been migrated to the current version. 

Included Docker containers pulled from a registry MUST include the tag and image ID in the version
file.

Example:
```
appliance=v1.2.0-rc1-118-ge50b7b1
harbor=harbor-offline-installer-v1.2.0.tgz
engine=vic_1.2.1.tar.gz
admiral=vmware/admiral:vic_v1.2.1 1fa8a0f5ec6d
vic-machine-server=gcr.io/eminent-nation-87317/vic-machine-server:latest 22b9d53190ff
```

Components SHOULD maintain internal versioning in their datastores. These versions should be useful
for determining upgrade paths.


## Component Inclusion

### Security

Each component is responsible for its application security posture. The Appliance team will work
with the component team to ensure that the component is run in accordance with security best
practices. 

Components should generally run as a Docker container. 
All processed on the Appliance should run with the least privilege required.


## Filesystem layout

Log files will be stored in a per component directory under `/mnt/log`
Example:
- `/mnt/log/admiral`
- `/mnt/log/harbor`

Data will be stored in a per component directory under `/data`
Example:
- `/data/admiral`
- `/data/harbor`

Databases will be stored in a per component directory under `/mnt/db`
Example:
- `/mnt/db/admiral`
- `/mnt/db/harbor`

System files will be stored in appropriate directories under `/` 
Example:
-  - component systemd unit files
-  - component startup scripts


## Logging

- Components that produce logs SHOULD log to a file
- Components SHOULD handle log file rotation
- Components MUST have a reasonable default configuration for log file size and number
- Components MAY accept and follow a configuration for max log file size
- Components MAY accept and follow a configuration for max number of log files


## Data storage

- Components SHOULD use variables for volume mounts in compose files
- Components MAY specify a volume for each of the following:
  - Data such as TLS certificates and configuration files
  - Database data
  - Logs

  This allows for the Appliance to manage data by putting it on separate disks if necessary.


## Continuous Integration (CI)

The Appliance will be built by a CI pipeline that is triggered when a new build of a component is
available. 

- All components MUST trigger the CI pipeline when a new version of the component is available
- Components MUST document what 


## Appliance Upgrade

The appliance upgrade process involves deploying a new version of the Appliance to the same vCenter
server, powering down the Guest OS of the old Appliance, moving the data disk(s) from the old
Appliance to the new Appliance, and powering on the new Appliance.

After power on, a script will be run (currently run by user via SSH) to perform upgrade and data
migration of each component.

### Requirements

- Running the overall upgrade script MUST be idempotent
- Running the component upgrade script MUST be idempotent
- A failure in the component upgrade script MUST return a nonzero exit code
- Component developers SHOULD communicate with the Appliance team a user friendly error
  message to display upon receiving a nonzero exit code
- Component developers SHOULD 
