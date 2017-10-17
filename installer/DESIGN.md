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


- Components SHOULD be 

## Logging


### Requirements

- Components SHOULD define a 

## Data storage

## Continuous Integration

All components should trigger 

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
