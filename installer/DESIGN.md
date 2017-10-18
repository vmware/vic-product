# VIC Appliance Design

## Introduction

This document covers the design for the VIC Appliance and specifies the requirements for components
("Component") to be included in the VIC Appliance ("Appliance").

The current state of the Appliance may not be in full compliance with the design. These cases will
be noted in this document and updated once the issue is resolved.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in
[RFC 2119](https://tools.ietf.org/html/rfc2119).


## Design Principles

The OVA includes several components developed by various teams. Each Component team is responsible
for the software quality of their component, for delivering the component artifact(s), and for
managing upgrade functionality of the component within the guidelines of this document.

The Component team will work with the Appliance team to manage the lifecycle of the process and
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

Example version file
```
appliance=v1.2.0-rc1-118-ge50b7b1
harbor=harbor-offline-installer-v1.2.0.tgz
engine=vic_1.2.1.tar.gz
admiral=vmware/admiral:vic_v1.2.1 1fa8a0f5ec6d
vic-machine-server=gcr.io/eminent-nation-87317/vic-machine-server:latest 22b9d53190ff
```

Components SHOULD maintain internal versioning in their datastores. These versions should be useful
for determining upgrade paths.

### Requirements

- A component artifact MUST have a version number that is different for each build

  A unique build number is necessary to identify the contents of the Appliance and for
  troubleshooting. 

- A component version number SHOULD include the git tag

- Development builds of a component SHOULD have a version number that is increments for each build

  A build number that increments aids in determining the latest version when building the Appliance.


## Component Inclusion

Components are pulled in by the build to create the Appliance. Components may depend on additional
artifacts. These artifacts can be pulled into the build and included in the Appliance, but must
follow the same versioning and inclusion requirements, though they might not have end to end tests
independent of those for the Component.

The nature of the Appliance build process means that a build failure from one component blocks
development for all other teams. The Component team should be aware of the status of the Appliance
build that results from their artifact and should take responsibility for build failures. 

### Security

Each component is responsible for its application security posture. The Appliance team will work
with the Component team to ensure that the component is run in accordance with security best
practices. 

Components should generally run as a Docker container. 
All processes on the Appliance should run with the least privilege required.

### Requirements

- In the case of a failing build, the Component team that triggered the failing Appliance build MUST
  take leadership of returning the build to a normal state and assign that effort a high priority.

  The team in charge should alert the Appliance team and other stakeholders through Slack that work
  to fix the build is in progress. If an extended breakage is expected, the team should give regular
  progress updates to stakeholders (at least once per day).

- The Component team MUST document and provide the Appliance team with acceptance tests for features
  that need to be tested.

  The Appliance team performs automated and manual testing for release acceptance. The component
  team must make the Appliance team aware of testing that needs to take place. Automated tests
  provided by the Component team are highly recommended and can be integrated with the Appliance
  team's automated test pipeline. 

- The Component team MUST NOT rely on Appliance team for manual testing of component functionality.

  The Component team is responsible for its component's software quality. Testing should be
  performed before handing off an artifact to the Appliance team and end to end testing should be
  performed on the resulting appliance.


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
- Components SHOULD handle their own log file rotation
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
available. Development builds will pull in the latest version of all components available at the
time of the build.

- All components MUST trigger the CI pipeline when a new version of the component is available

  The recommended way to trigger the build is by using Drone downstream project triggers.


## Appliance Upgrade

The appliance upgrade process involves deploying a new version of the Appliance to the same vCenter
server, powering down the Guest OS of the old Appliance, moving the data disk(s) from the old
Appliance to the new Appliance, and powering on the new Appliance.

After power on, an Appliance upgrade script will be run (currently run by user via SSH) to perform
upgrade and data migration of each component by calling a component upgrade script for each
component.

### Requirements

- Running the Appliance upgrade script MUST be idempotent

  Users may run the upgrade script multiple times, but this must not corrupt any data or otherwise
  cause failure of any services running on the Appliance.

- Running the component upgrade script MUST be idempotent

  The Appliance upgrade script may call the component upgrade script multiple times, but this must
  not corrupt any data. If no operation is performed, the component upgrade script should exit with
  a zero exit code.

- A failure in the component upgrade script MUST return a nonzero exit code

  The Appliance upgrade script needs to be able to detect any failure in the component upgrade
  script, otherwise the upgrade is assumed to be successful.

- Component developers SHOULD communicate with the Appliance team a user friendly error
  message to display upon receiving a nonzero exit code

  If the component upgrade fails, the overall upgrade script needs to be able to alert the user.
  This will also be helpful for troubleshooting.

- Component developers MUST test upgrade scenarios as part of regular development testing

  Upgrade is a fully supported operation and needs to be thorougly tested. It is recommended to
  generate a realistic dataset for testing.

- A component upgrade script MUST be versioned with the same version number as its coresponding
  component artifact

  The contents of component upgrade scripts will change over time. The component upgrade script
  needs to be treated a component TODO

- A component upgrade script MUST NOT corrupt application data if run against an incompatible
  version or incompatible data
