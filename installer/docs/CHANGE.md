# Change Impact Assessment

This document serves as a checklist to assess the impact of changes. It should be used during the
design and validation stages of the development process to ensure that all aspects of a change's
potential impact are known.

This document is ordered based on the [Appliance
Lifecycle](https://github.com/vmware/vic-product/blob/master/installer/docs/SUPPORT.md#appliance-lifecycle)
with the addition of development related stages.

## Impact Assessment

### Development

- [ ] Design document needed?
- [ ] User documentation
- [ ] Updated appliance-support.sh
- [ ] Updated SUPPORT.md
- [ ] Technical debt? New issue opened to address debt?
- [ ] Integration with components
- [ ] Updated INTEGRATION.md and existing integration documentation
- [ ] Conforms to [VIC Appliance Design](DESIGN.md)

### Testing

- [ ] Test plan created or updated
- [ ] Unit testing
- [ ] Integration testing
- [ ] Tests added in CI

### Release

- [ ] Process documented in RELEASE.md
- [ ] Versioning
- [ ] CI artifact upload
- [ ] Automated release process

### Deployment Stage

- [ ] User experience
- [ ] Documentation updates for customizations
- [ ] Deployment with static IP
- [ ] Deployment with user provided TLS certificate

### Boot Stage

- [ ] User experience
- [ ] Account for diverse network configurations

### Initialization Stage

- [ ] User experience
- [ ] PSC integration, internal and external PSC
- [ ] Getting Started Page

### Running Stage

- [ ] User experience

### Appliance Upgrade Stage

- [ ] User experience
- [ ] VIC appliance upgrade
- [ ] Tested valid upgrade paths
- [ ] Cleanup from previous upgrade operations
- [ ] Upgrade interaction with Admiral
- [ ] Upgrade interaction with Harbor
- [ ] Upgrade documentation

## Additional Information

- [VIC Appliance Design](https://github.com/vmware/vic-product/blob/master/installer/DESIGN.md)
