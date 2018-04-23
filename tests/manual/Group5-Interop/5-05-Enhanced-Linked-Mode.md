Test 5-5 - Enhanced Linked Mode
=======

# Purpose:
To verify the VIC appliance and Wizard UI works in when the vCenter appliance is using enhanced linked mode

# References:
[1 - VMware vCenter Server Availability Guide](http://www.vmware.com/files/pdf/techpaper/vmware-vcenter-server-availability-guide.pdf)

# Environment:
This test requires access to VMWare Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy two new vCenters in Nimbus each with one ESXi host configured
2. Establish an enhanced link between the two vCenters
3. Install the VIC OVA appliance
4. Walk through completing the install and use the VCH creation wizard to create a VCH
5. Run a variety of docker commands on the VCH appliance

# Expected Outcome:
The VCH and VIC appliance should deploy without error and each of the docker commands executed against it should return without error

# Possible Problems:
None
