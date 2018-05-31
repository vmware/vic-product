# VIC Appliance Component Integration Documentation

## Harbor

### Component Requirements
- What is the Docker container or Docker Compose application that will be included in the appliance?
  `vmware/redis-photon`
  `vmware/clair-photon`
  `vmware/notary-server-photon`
  `vmware/notary-signer-photon`
  `vmware/nginx-photon`
  `vmware/harbor-log`
  `vmware/harbor-jobservice`
  `vmware/harbor-ui`
  `vmware/mariadb-photon`
  `vmware/postgresql-photon`
  `vmware/harbor-adminserver`
  `vmware/harbor-db`
  `vmware/harbor-migrator`
  `vmware/registry-photon`

    - Release versions MUST be retained. Where will previously released versions be stored?
      `gcr.io/eminent-nation-87317/harbor-releases/${release_branch}/${release_build}`
      
- What is the component's naming scheme for development and release builds?
  Component is delivered as a tgz file named `harbor-offline-installer-${tag}-build.${drone_job_id}.tgz` for development and 
  `harbor-offline-installer-${tag}.tgz` for release builds

- What is the component's versioning scheme for development and release builds?
  Development builds are named as `harbor-offline-installer-${tag}-build.${drone_job_id}.tgz`, the drone job id is used for version.
  Release builds are named as `harbor-offline-installer-${tag}.tgz`, the ${tag} is used for the version.

- Aside from the primary component, are there other dependencies maintained by the component team
  that need to be included in the VIC appliance? 
  NO

    - How are these delivered?
    - Consider a branching strategy for ongoing development on master while maintaining versions
      included with previous release versions
        - Release versions MUST be retained. Where will previously released versions be stored?
        - How will the component team notify the VIC appliance team to pull in a new version?
        - How are these dependencies versioned?

- Does the component need a separate disk? (such as `/storage/db`)
  `/storage/db`, `/storage/data` and `/storage/log`

    - What is the default size in GB?
    N/A

- Describe the requirements the platform must provide for the component
    - Examples: OS packages, certificates, token files, configuration
    - Specify the location the component expects any dependencies to be on the filesystem:
  Requires values of hostname, ui_url_protocol, ssl_cert, ssl_cert_key, secretkey_path and admiral_url in `/storage/data/harbor/harbor.cfg`
  Requires `ca.crt` in `/storage/data/harbor/ca_download` with permission 10000:10000
  Requires `tokens.properties` in `/storage/data/harbor/psc` with permission 10000:10000 

### Runtime
- What configuration must be present for the service to start?
  `/etc/vmware/harbor/common` and `/storage/data/harbor/harbor.cfg`

    - The canonical method for providing configuration to a Docker Compose application is through
      environment variables: https://docs.docker.com/compose/environment-variables/#the-env-file
        - Will the component use the default `.env` file? https://docs.docker.com/compose/env-file/
            - If not, specify the environment file:
        - What default values will the VIC appliance need to override?
- What volumes need to be   mounted to the container or application? 
  The volumes need to be mounted should refer to the docker compose yml files in `/etc/vmware/harbor/common`.

- Specify networking requirements
    - External networking:
      Port 443/9443 TCP allowed
    - Will the component connect to the appliance's `vic-appliance` network?
      https://docs.docker.com/compose/networking/#use-a-pre-existing-network
      NO

- Does the component require any other components to be running before it starts?
  Requires `psc-ready.target` is running before Harbor starts.

- Are there any steps that need to be performed before starting the component?
  NO

- Should a script be run before starting the component?
  Ensure the `/etc/vmware/harbor/prepare` script is executed.

- How do you start the component?
  `docker-compose -f /etc/vmware/harbor/docker-compose.yml -f /etc/vmware/harbor/docker-compose.notary.yml -f /etc/vmware/harbor/docker-compose.clair.yml up -d`

- How do you stop the component?
  `docker-compose -f /etc/vmware/harbor/docker-compose.yml -f /etc/vmware/harbor/docker-compose.notary.yml -f /etc/vmware/harbor/docker-compose.clair.yml down -v`

- Are there any steps that need to be performed after the component stops?
  NO

- Are there any additional runtime requirements?
  NO

### Continuous Integration
- Link to .drone.yml that triggers downstream `vic-product` build:
  Built by `vmware/harbor` https://github.com/vmware/harbor/blob/master/.drone.yml

- Where will the VIC appliance build obtain component artifacts?
  Load from harbor offline installer
  
    - Link to bucket that will contain development builds: `gcr.io/eminent-nation-87317/harbor-builds`
    - Link to bucket that will contain tagged builds for releases (including release candidates):
      `gcr.io/eminent-nation-87317/harbor-releases/${branch_name}`
    - How will the VIC appliance build recognize what artifact to pick up?
      `gcr.io/eminent-nation-87317/harbor-builds/master.stable` for development builds, this file holds the URL of stable build.
      `gcr.io/eminent-nation-87317/harbor-releases/${release_branch}/harbor-offline-installer-${tag}.tgz` for release builds

        - Will there be other artifacts in the bucket? If so, component team MUST guarantee that the
          value provided above will identify the correct artifact 
          NO

### Appliance Upgrade
- Does the component specific upgrade script meet the requirements of the design doc?
  https://github.com/vmware/vic-product/blob/master/installer/docs/DESIGN.md#upgrade-requirements
  Beside the log level, the harbor-migrator has already covered the requirements defined in the desgin doc.

- How does the VIC appliance team know when a change needs to be made to the component specific
  upgrade script? (This question is about the responsibility for the component upgrade script)

    - Should the upgrade script be in component repo? As a container?
      It's packed into harbor offline installer as a docker image, named as vmware/harbor-migrator
    - How will the upgrade script be versioned?
      Use the image tag as version, like vmware/harbor-migrator:v1.5.0

- How are configuration changes handled during upgrade?
  The migrator will migrate the needed items of harbor.cfg to the latest version by copying, and set the default value to the newly added items. Also, the migrator will upgarde the DB scheme to latest.

- Are there additional upgrade requirements?
  NO
