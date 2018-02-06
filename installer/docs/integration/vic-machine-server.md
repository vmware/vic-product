# VIC Appliance Component Integration Documentation

## VIC Machine Server

### Component Requirements
- What is the Docker container or Docker Compose application that will be included in the appliance?
  `gcr.io/eminent-nation-87317/vic-machine-server`

    - Release versions MUST be retained. Where will previously released versions be stored?
      `gcr.io/eminent-nation-87317/vic-machine-server`
      
- What is the component's naming scheme for development and release builds?
  Component is delivered as a container named `vic-machine-server` for both development and release
  builds

- What is the component's versioning scheme for development and release builds?
  Development builds are tagged `latest`
  Release builds are not tagged, pending https://github.com/vmware/vic-product/issues/1250

- Aside from the primary component, are there other dependencies maintained by the component team
  that need to be included in the VIC appliance? 
  NO

    - How are these delivered?
    - Consider a branching strategy for ongoing development on master while maintaining versions
      included with previous release versions
        - Release versions MUST be retained. Where will previously released versions be stored?
        - How will the component team notify the VIC appliance team to pull in a new version?
        - How are these dependencies versioned?

- Does the component need a separate disk? (such as /storage/db)
  NO

    - What is the default size in GB?

- Describe the requirements the platform must provide for the component
    - Examples: OS packages, certificates, token files, configuration
    - Specify the location the component expects any dependencies to be on the filesystem:
  Certificates at volume mounted to container at `/certs`. Requires `server.crt` and `server.key`

### Runtime
- What configuration must be present for the service to start?
  N/A

    - The canonical method for providing configuration to a Docker Compose application is through
      environment variables: https://docs.docker.com/compose/environment-variables/#the-env-file
        - Will the component use the default `.env` file? https://docs.docker.com/compose/env-file/
            - If not, specify the environment file:
        - What default values will the VIC appliance need to override?
- What volumes need to be mounted to the container or application? The number of volumes should be
  minimized.
  `/storage/data/certs:/certs:ro`
  `storage/log/vic-machine-server:/var/log/vic-machine-server`

- Specify networking requirements
    - External networking:
      Port 8443 TCP allowed
    - Will the component connect to the appliance's `vic-appliance` network?
      https://docs.docker.com/compose/networking/#use-a-pre-existing-network
      NO

- Does the component require any other components to be running before it starts?
  NO

- Are there any steps that need to be performed before starting the component?
  Ensure no other `vic-machine-server` containers present

- Should a script be run before starting the component? This should be avoided if possible.
  Minimal - create log directory and open port

- How do you start the component?
  `docker run --rm --user 10000:10000 --name vic-machine-server -v /storage/data/certs:/certs -v
  /storage/log/vic-machine-server:/var/log/vic-machine-server -p ${VIC_MACHINE_SERVER_PORT}:443
  vmware/vic-machine-server:ova`

- How do you stop the component?
  `docker stop vic-machine-server`

- Are there any steps that need to be performed after the component stops?
  NO

- Are there any additional runtime requirements?
  NO

### Continuous Integration
- Link to .drone.yml that triggers downstream `vic-product` build:
  Built by `vmware/vic` https://github.com/vmware/vic/blob/master/.drone.yml

- Where will the VIC appliance build obtain component artifacts?
  Pull from `gcr.io/eminent-nation-87317/vic-machine-server`
  
    - Link to bucket that will contain development builds: `gcr.io/eminent-nation-87317/vic-machine-server`
    - Link to bucket that will contain tagged builds for releases (including release candidates):
      TODO
    - How will the VIC appliance build recognize what artifact to pick up?
      `latest` tag for development builds
      TODO tag for release builds

        - Will there be other artifacts in the bucket? If so, component team MUST guarantee that the
          value provided above will identify the correct artifact 
          NO

### Appliance Upgrade
- Does the component specific upgrade script meet the requirements of the design doc?
  https://github.com/vmware/vic-product/blob/master/installer/DESIGN.md#requirements-3
  N/A - replace the container

- How does the VIC appliance team know when a change needs to be made to the component specific
  upgrade script? (This question is about the responsibility for the component upgrade script)

    - Should the upgrade script be in component repo? As a container?
    - How will the upgrade script be versioned?

- How are configuration changes handled during upgrade?
  N/A - no persistent config

- Are there additional upgrade requirements?
  NO
