Test 5-03 - Multiple Datacenter
=======

# Purpose:
To verify the VIC OVA appliance works when the vCenter appliance has multiple datacenters

# References:
[1 - VMware vCenter Server Availability Guide](http://www.vmware.com/files/pdf/techpaper/vmware-vcenter-server-availability-guide.pdf)

# Environment:
This test requires access to VMware Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a new vCenter with 3 different datacenters and a mix of ESX within the datacenters
2. Install the VIC OVA appliance into one of the datacenters
3. Run regression tests on the VIC OVA appliance

# Expected Outcome:
The VIC OVA appliance should deploy without error and regression tests should pass

# Possible Problems:
None