# VIC Appliance Design

## Introduction

This document covers the design for the VIC Appliance and specifies the requirements for components
to be included in the VIC Appliance.

The current state of the appliance may not be in full compliance with the design. These cases will
be noted in this document and updated once the issue is resolved.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in
[RFC 2119](https://tools.ietf.org/html/rfc2119).


## Design Principles

The OVA includes several components developed by various teams. Each component team is responsible
for the software quality of their component, for delivering the component artifact(s), and for
managing upgrade functionality of the component within the guidelines of this document.

The appliance is based on [Photon OS](https://github.com/vmware/photon) and uses Systemd for process
management. Component processes are run as Docker containers unless there is a strong justification
for a different inclusion method.

The appliance team will provide a reference set of Systemd unit files and an example service that
can be adapted by the component team to suit their service.

The component team will work with the appliance team to manage the lifecycle of the process and
integrate the component with the appliance. The component team is ultimately responsible for the
Systemd units related to their component, but the component team should work with the appliance team
during the integration process. This means that component developers should understand [how to build
the appliance](BUILD.md) for testing during the development process.

### Reference Service

_TODO_ Add reference service to repo

- Configuration of a service SHOULD take place in `ExecStartPre` statement(s) of the component unit

  This simplifies the service's units, but means that the configuration step needs to be designed
  with the expectation that it will be run every time the service starts.

- If configuration of a service requires a separate lifecycle, the service MAY have a separate
  `configure-<service>.service` unit in addition to `<service>.service`

- A component unit SHOULD directly execute the `docker run` command in `ExecStart` and SHOULD NOT
  execute a script that then starts the service

- A component unit SHOULD specify starting another service through unit dependency directives and
  SHOULD NOT directly execute `systemctl`

- A component's dependencies SHOULD be separate Systemd services

  This allows the component to specify the startup and shutdown behavior through unit dependency
  directives such as `Wants`, `Requires`, `Before`, and `After`.

- A component unit file MUST have a `Requires=vic-appliance-ready.service` and
  `After=vic-appliance-ready.service` statement

  This target ensures that the prerequisites for component services including disk, network,
  firewall, and Docker are ready before the component starts.

### Requirements

- A normally functioning component SHOULD NOT contain error messages in its logs or in the system
  logs for its systemd unit

  During troubleshooting and testing, unnecessary error logs will cause confusion.

- A degraded component SHOULD display a user friendly error message through its primary UI

  Components should not silently exclude expected functionality and should notify users if the
  component is not functioning normally.

- A degraded component SHOULD log messages relevant to troubleshooting

  Components should not silently exclude expected functionality and should assist in determining the
  cause of failure.

- A failed component MUST exit cleanly or degrade to displaying a user friendly error message
  through its primary UI

  Failed components should not affect other unrelated processes still running on the appliance.
  Components should not silently exclude expected functionality and should notify users if the
  component is not functioning normally.

- A failed component MUST exit with a nonzero exit code if it is unable to gracefully degrade

  Exiting in this manner will assist in identification of the failure during troubleshooting.

- The component team is responsible for creating and maintaining the Systemd units and other
  lifecycle management of the component with the appliance team assisting with integration and
  ensuring best practices are followed


## Versioning

_TODO_ Document naming convention

The version of each component MUST be recorded during the appliance build and included in the
appliance artifact in the file `/etc/vmware/version` and `/storage/data/version`.

After a successful appliance upgrade, the system version file MUST overwrite the previous data disk
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
for determining upgrade paths. For example, in order to prevent data corruption by a component
operating on an incompatible version of the database, during normal operation, upgrade, or
otherwise, the database should store a version number of the data and perform a compatibility
check before operating on the data. 

### Requirements

- A component artifact MUST have a version number that is different for each build

  A unique build number is necessary to identify the contents of the appliance and for
  troubleshooting. 

- A component version number SHOULD include the git tag

- Development builds of a component SHOULD have a version number that is increments for each build

  A build number that increments aids in determining the latest version when building the appliance.

- Component configuration files SHOULD be versioned

  A configuration version number is useful for determining upgrade paths. The configuration version
  number is not required to be the same as the component version number, but it is recommended that
  the configuration version number be useful in checking compatibility during upgrade.


## Component Inclusion

Components are pulled in by the build to create the appliance. Components may depend on additional
artifacts. These artifacts can be pulled into the build and included in the appliance, but must
follow the same versioning and inclusion requirements, though they might not have end to end tests
independent of those for the component. The distinction between a component and an "additional
artifact" is that "additional artifacts" are treated as libraries used by a component and do not
undergo testing independent of the component by the appliance team.

An example of an "additional artifact" is the PSC jar file that is used by Admiral for interacting
with the PSC. Admiral depends on this file, but it is not a standalone service. The artifact needs
to be versioned and tested by the component team. Direct testing of the PSC jar functionality
will not be done by the appliance team.

An example of something that is not an "additional artifact" is the VIC Machine API service that
runs on the appliance. This service is an independent component. 

The nature of the appliance build process means that a build failure from one component blocks
development for all other teams. The component team MUST be aware of the status of the appliance
build that results from their artifact and MUST take responsibility for build failures.

Since the appliance build must be kept in "passing" state, each component team is required to do any
appliance integration testing specific to that component, including upgrade. This means that the
teams should invest in automated testing and as part of the component team's CI/CD (or leveraging
the appliance CI/CD) test the candidate component before pushing that component to be included in
the current appliance build.

### Security

Each component is responsible for its application security posture. The appliance team will work
with the component team to ensure that the component is run in accordance with security best
practices. 

Components SHOULD run as a Docker container unless there is strong justification for a different
inclusion method that is approved by the appliance team.
All processes on the appliance should run with the least privilege required.

TODO Add how to deprivilege Docker container

### Requirements

- In the case of a failing build, the component team that triggered the failing appliance build MUST
  take leadership of returning the build to a normal state and assign that effort a high priority

- In the case of a failing build, the component team in charge MUST alert the appliance team and
  other stakeholders through Slack that work to fix the build is in progress. If an extended
  breakage is expected, the team MUST give regular progress updates to stakeholders (at least once
  per day).

- The component team MUST document and provide the appliance team with acceptance tests for features
  that need to be tested

  The appliance team performs automated and manual testing for release acceptance. The component
  team must make the appliance team aware of testing that needs to take place. Automated tests
  provided by the component team are highly recommended and can be integrated with the appliance
  team's automated test pipeline. 

- The component team MUST NOT rely on appliance team for manual testing of component functionality

  The component team is responsible for its component's software quality. Testing should be
  performed before handing off an artifact to the appliance team and end to end testing should be
  performed on the resulting appliance.

- User ID `10000` MUST be used as the unprivileged user for components

- All shell scripts MUST be checked using ShellCheck and errors all errors resolved prior to
  inclusion

  https://github.com/koalaman/shellcheck


## Filesystem Layout

Log files will be stored in a per component directory under `/mnt/log`
Example:
```
- /storage/log/admiral
- /storage/log/harbor
```

Data will be stored in a per component directory under `/data`
Example:
```
- /storage/data/admiral
- /storage/data/harbor
```

Databases will be stored in a per component directory under `/mnt/db`
Example:
```
- /storage/db/admiral
- /storage/db/harbor
```

System files will be stored in appropriate directories under `/` 
Example:
```
Appliance Systemd unit files:
- /usr/lib/systemd/system

Appliance startup scripts:
- /etc/vmware

Component Systemd unit files:
- /usr/lib/systemd/system

Component startup scripts:
- /etc/vmware/admiral
- /etc/vmware/harbor
```

The appliance provides a TLS certificate in `/storage/data/certs/`. The system generates a
self-signed TLS certificate or places a user specified TLS certificate in this directory. All
components should use this certificate for user facing connections and can access it by mounting
this directory as a read only volume to the component container
(`-v /storage/data/certs:/path/on/container:ro`)

`/storage/data/certs/` contains:
```
- ca.crt
- ca.key
- ca.srl
- cert_gen_type
- extfile.cnf
- server.cert.pem
- server.csr
- server.key.pem # PKCS1 format private key
```


## Logging

- Components that produce logs SHOULD log to a file
- Components SHOULD handle their own log file rotation
- Components MUST have a reasonable default configuration for log file size and number
- Components MAY accept and follow a configuration for max log file size
- Components MAY accept and follow a configuration for max number of log files

In the future the appliance will provide a remote logging capability. 


## Data storage

- Components MUST use variables for volume mounts in compose files

  This documentation shows how to use variables:
  https://docs.docker.com/compose/compose-file/#variable-substitution
  https://docs.docker.com/compose/environment-variables/

  The component team should work with the appliance team for integration of the correct volume
  mounts.

- Components MAY specify a volume for each of the following:
  - Data such as TLS certificates and configuration files
  - Database data
  - Log files

  This allows for the appliance to manage data by putting it on separate disks if necessary.
  Component developers should communicate with the appliance team the expected scale of various
  categories of data stored by the component to ensure proper disk sizing.


## Continuous Integration (CI)

The appliance will be built by a CI pipeline that is triggered when a new build of a component is
available. Development builds will pull in the latest version of all components available at the
time of the build.

- All components MUST trigger the CI pipeline when a new version of the component is available

  The recommended way to trigger the build is by using Drone downstream project triggers.

- It is recommended for components to have a staging branch and staging artifact upload workflow
  integrated with the CI system to test integration with the appliance before making available
  component artifacts for inclusion in the appliance development or release build

  This architecture will prevent the main appliance build from being blocked by a failing component
  build. The component team should work with the appliance team to integrate this workflow with the
  respective CI systems.


## Appliance Upgrade

The appliance upgrade process involves deploying a new version of the appliance to the same vCenter
server, powering down the Guest OS of the old appliance, moving the data disk(s) from the old
appliance to the new appliance, and powering on the new appliance.

After power on, an appliance upgrade script will be run (currently run by user via SSH) to perform
upgrade and data migration of each component by calling a component upgrade script for each
component.

The upgrade script is located at `/etc/vmware/upgrade/upgrade.sh` and its debug logs are written to
`/var/log/vmware/upgrade.log`.

In the future the upgrade process will be fully automated. Current development should take this goal
into account. We expect that this will first be accomplished by providing a script to perform the
move of the data disk(s) and the running of the upgrade script. The next iteration would be to have
the current version of the appliance perform this action through a UI.


### Requirements

- Component developers MUST test upgrade scenarios as part of regular development testing

  Upgrade is a fully supported operation and needs to be thorougly tested. It is recommended to
  generate a realistic dataset for testing.

- Running the appliance upgrade script MUST be idempotent

  Users may run the upgrade script multiple times, but this must not corrupt any data or otherwise
  cause failure of any services running on the appliance.

- Running the component upgrade script MUST be idempotent

  The appliance upgrade script may call the component upgrade script multiple times, but this must
  not corrupt any data. If no operation is performed, the component upgrade script should exit with
  a zero exit code.

- A failure in the component upgrade script MUST return a nonzero exit code

  The appliance upgrade script needs to be able to detect any failure in the component upgrade
  script, otherwise the upgrade is assumed to be successful.

- Component teams MUST handle configuration migration/upgrade as part of the upgrade process

  Configuration migration may happen within the component upgrade script or as a separate script.
  Testing for configuration migration with a comprehensive set of values must be included by the
  component team during the upgrade development process.

- Component developers SHOULD communicate with the appliance team a user friendly error
  message to display upon receiving a nonzero exit code

  If the component upgrade fails, the overall upgrade script needs to be able to alert the user.
  This will also be helpful for troubleshooting. Component developers should consider providing a
  mapping of exit codes to error messages so that a relevant error message can be displayed.

- A component upgrade script SHOULD output debug level logs to stdout

  These logs will be saved in `/var/log/vmware/upgrade.log`.

- A component upgrade script MUST be versioned with the same version number as its coresponding
  component artifact

  The contents of component upgrade scripts will change over time. The component upgrade script
  needs to be treated a component with versioning so that the appliance build can pull in the
  appropriate version.

- A component upgrade script MUST NOT corrupt application data if run against an incompatible
  version or incompatible data

- The appliance upgrade script MUST NOT require human knowledge of the upgrade path

  The appliance upgrade script needs to automatically detect appliance version to determine what
  upgrade actions to perform. This process paired with version-awareness of component upgrade
  scripts is part of ensuring that the upgrade process does not corrupt data and improves the
  upgrade user experience.

## Appliance Rollback

Rollback is not currently implemented, but will be considered in the future.
