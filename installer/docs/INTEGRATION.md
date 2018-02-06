# VIC Appliance Component Integration Documentation

The responses to the considerations in this document will serve as the interface between the VIC appliance and each component it includes. 

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in
[RFC 2119](https://tools.ietf.org/html/rfc2119).

Each component MUST document and maintain a current copy of [Component Inclusion](#component-inclusion). Before the interface is modified, the component team MUST coordinate with the VIC appliance team to agree on integration.

## Component Inclusion

### Component Requirements
- What is the component's naming scheme for development and release builds?
- What is the component's versioning scheme for development and release builds?
- What is the Docker container or Docker Compose application that will be included in the appliance?
    - Release versions MUST be retained. Where will previously released versions be stored? 
- Aside from the primary component, are there other dependencies maintained by the component team that need to be included in the VIC appliance? 
    - How are these delivered?
    - Consider a branching strategy for ongoing development on master while maintaining versions included with previous release versions
        - Release versions MUST be retained. Where will previously released versions be stored?
        - How will the component team notify the VIC appliance team to pull in a new version?
        - How are these dependencies versioned? 
- Does the component need a separate disk? (such as /storage/db)
    - What is the default size in GB?
- Describe the requirements the platform must provide for the component
    - Examples: OS packages, certificates, token files, configuration
    - Specify the location the component expects any dependencies to be on the filesystem:

### Runtime
- What configuration must be present for the service to start?
    - The canonical method for providing configuration to a Docker Compose application is through environment variables: https://docs.docker.com/compose/environment-variables/#the-env-file
        - Will the component use the default `.env` file? https://docs.docker.com/compose/env-file/
            - If not, specify the environment file:
        - What default values will the VIC appliance need to override?
- What volumes need to be mounted to the container or application? The number of volumes should be minimized.
- Specify networking requirements
    - External networking:
    - Will the component connect to the appliance's `vic-appliance` network? https://docs.docker.com/compose/networking/#use-a-pre-existing-network
- Does the component require any other components to be running before it starts?
- Are there any steps that need to be performed before starting the component?
- Should a script be run before starting the component? This should be avoided if possible.
- How do you start the component?
- How do you stop the component?
- Are there any steps that need to be performed after the component stops?
- Are there any additional runtime requirements?

### Continuous Integration
- Link to .drone.yml that triggers downstream `vic-product` build:
- Where will the VIC appliance build obtain component artifacts?
    - Link to bucket that will contain development builds:
    - Link to bucket that will contain tagged builds for releases (including release candidates):
    - How will the VIC appliance build recognize what artifact to pick up?
        - Will there be other artifacts in the bucket? If so, component team MUST guarantee that the value provided above will identify the correct artifact 

### Appliance Upgrade
- Does the component specific upgrade script meet the requirements of the design doc? https://github.com/vmware/vic-product/blob/master/installer/DESIGN.md#requirements-3
- How does the VIC appliance team know when a change needs to be made to the component specific upgrade script? (This question is about the responsibility for the component upgrade script)
    - Should the upgrade script be in component repo? As a container?
    - How will the upgrade script be versioned?
- How are configuration changes handled during upgrade?
- Are there additional upgrade requirements?

    
## Additional Information

- [VIC Appliance Design Document](https://github.com/vmware/vic-product/blob/master/installer/DESIGN.md)
