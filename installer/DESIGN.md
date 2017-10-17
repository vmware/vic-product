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



## Component Inclusion

### Requirements

- A failing component MUST exit cleanly TODO describe
- A failing component MUST exit with a nonzero exit code if it is not in usable condition
- A normally functionoing component SHOULD NOT contain error messages in its logs


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
- Component developers SHOULD communicate with the Appliance development team a user friendly error
  message to display upon receiving a nonzero exit code
- Component developers SHOULD 
