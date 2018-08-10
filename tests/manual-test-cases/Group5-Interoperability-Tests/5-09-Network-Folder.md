Test 5-09 - Network Folder
=======

# Purpose:
To verify the VIC OVA appliance and Wizard UI works when the vCenter appliance has port groups in a DVS under a network folder

# References:
[1 - VMware vCenter Server Availability Guide](http://www.vmware.com/files/pdf/techpaper/vmware-vcenter-server-availability-guide.pdf)

# Environment:
This test requires access to VMware Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a new vCenter with a distributed virtual switch with 3 portgroups under a network folder
2. Install the VIC OVA appliance
3. Walk through completing the install and use the VCH creation wizard to create a VCH
4. Run a variety of docker commands on the VCH appliance

# Expected Outcome:
The VCH and VIC appliance should deploy without error and each of the docker commands executed against it should return without error

# Possible Problems:
None
