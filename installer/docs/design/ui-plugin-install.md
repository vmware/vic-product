# VIC Appliance UI Plugin Automated Installation Design Document

## Objectives

- Improve the UX of installing the VIC UI plugin

## Design

### Build

- The functionality currently contained in the VIC UI plugin install scripts in the `vmware/vic-ui` repo and the `vic-ui` binary in the `vmware/vic` repo will be removed from those repos and reside in the `vmware/vic-product` repo. Since this functionality will be tightly integrated with the VIC appliance and is not anticipated to require significant ongoing development, this code does not need to be built or versioned independently of the VIC appliance.

### Deployment

- The user will deploy the VIC appliance as normal.
- During the Initialization stage of the VIC appliance, the user will provide vSphere administrator credentials. The modal to collect this input currently exists and contains all of the necessary fields. After entering the information and before sending the credentials to vCenter, the user will be prompted to trust the TLS fingerprint of the vCenter.
	- If the fingerprint is not trusted, do not proceed. Display directions to contact support or link to documentation. 
- If the credentials are correct, begin the plugin installation. This will run the equivalent of the current `vic-ui-*` binary.
- Logging of the plugin install operations should be improved to facilitate debugging.
- The plugin will be installed without user intervention using the user provided information.
- If the plugin install succeeds, a confirmation message will be displayed on the Getting Started Page. This message will include directions to restart required services for the plugin to be activated in vCenter.
- If the plugin install fails, an error message will be displayed on the Getting Started Page. This message will include directions to contact support or link to documentation.
- In case the plugin install fails or reinstallation is later required, a method to redo the plugin install will be provided from the Getting Started Page. 
- The automated plugin install should also work with the `/register` API endpoint provided by `fileserver`.
- A manual process for running the plugin install should be documented and tested.
	- This may be either usage of the `/register` API or a standalone plugin install binary.

## Testing

- Tests for the automated install process should be added to the nightly test system since the UI
  plugin requires an isolated vSphere environment.
  - Tests should verify that errors are not returned during the plugin install.
  - Tests should login to the vSphere UI and verify that the plugin functions properly.
  - Tests should cover using both the UI and API. 
- If a standalone go binary is provided, this should also be tested, though manual tests may be
  sufficient if automated tests would require excessive engineering effort.

## References

- https://github.com/vmware/vic-product/issues/1432
