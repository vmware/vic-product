---
name: "Defect Report"
about: Report something that isn't working as expected

---

<!--
This repository is for VIC Product. Please use it to report issues related to the VIC Appliance (OVA) and user documentation.

To help use keep things organized, please file issues in the most appropriate repository:
 * vSphere Client Plugins: https://github.com/vmware/vic-ui/issues
 * VIC Engine (VCHs, Container VMs, and their lifecycles): https://github.com/vmware/vic/issues
 * Container Management Portal (Admiral): https://github.com/vmware/admiral/issues
 * Container Registry (Harbor): https://github.com/goharbor/harbor/issues
-->

#### Summary
<!-- Explain the problem briefly. -->


#### Environment information
<!-- Describe the environment where the issue occurred. -->

##### vSphere and vCenter Server version
<!-- Indicate the vSphere and vCenter Server version(s) being used. -->

##### VIC Appliance version
<!-- Indicate the full filename of the VIC Appliance version that you deployed (e.g., vic-vX.Y.Z-tag-NNNN-abcdef0.ova). -->

##### Configuration

- Embedded or external PSC:
- How was the OVA deployed? (Flex client, HTML5 client, ovftool):
- Does the VIC appliance recieve configuration by DHCP?
- What [stage of the Appliance Lifecycle][1] is the VIC appliance in?
<!-- OPTIONAL, but helpful: -->
- IP address of VIC appliance:
- Hostname of VIC appliance:
- IP address of vCenter Server:
- Hostname of vCenter Server:

[1]:https://github.com/vmware/vic-product/blob/master/installer/docs/SUPPORT.md#appliance-lifecycle


#### Details
<!-- Provide additional details. -->

##### Steps to reproduce
<!-- What operation was being performed when the failure was noticed? -->

##### Actual behavior
<!-- What happend? -->

##### Expected behavior
<!-- What did you expect to happen instead? -->

##### Support information
<!--
Provide information from the "Support Information" section of the appropriate Appliance Lifecycle stage:
  https://github.com/vmware/vic-product/blob/master/installer/docs/SUPPORT.md#appliance-lifecycle
-->


#### Logs
<!--
For issues related to the VIC appliance, please attach a log bundle (e.g. vic_appliance_logs_2018-01-01-00-01-00.tar.gz).
  https://github.com/vmware/vic-product/blob/master/installer/docs/SUPPORT.md#appliance-support-bundle
  Note: The support bundle may contain private information. If you are not comfortable with posting this publicly, please contact VMware GSS.
-->


#### See also
<!-- Provide references to relevant resources, such as documentation or related issues. -->


#### Troubleshooting attempted
<!-- Use this section to indicate steps you've already taken to troubleshoot the issue. -->

- [ ] Searched [GitHub][issues] for existing issues. (Mention any similar issues under "See also", above.)
- [ ] Searched the [documentation][docs] for relevant troubleshooting guidance.
- [ ] Searched for a relevant [VMware KB article][kb].

<!-- Reference-style links used above; removing these will break the links. -->
[issues]:https://github.com/vmware/vic-product/issues
[docs]:https://vmware.github.io/vic-product/#documentation
[kb]:https://kb.vmware.com/s/global-search/%40uri#t=Knowledge&sort=relevancy&f:@commonproduct=[vSphere%20Integrated%20Containers]
