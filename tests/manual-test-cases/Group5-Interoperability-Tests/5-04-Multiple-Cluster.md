Test 5-04 - Multiple Cluster
=======

# Purpose:
To verify the VIC OVA appliance and Wizard UI works when the vCenter appliance has multiple clusters within the datacenter

# References:
[1 - VMware vCenter Server Availability Guide](http://www.vmware.com/files/pdf/techpaper/vmware-vcenter-server-availability-guide.pdf)

# Environment:
This test requires access to VMware Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a new vCenter with 3 different clusters in a datacenter and a mix of ESX within the clusters
2. Install the VIC OVA appliance
3. Walk through completing the install and use the VCH creation wizard to create a VCH
4. Run a variety of docker commands on the VCH appliance

# Expected Outcome:
The VCH and VIC appliance should deploy without error and each of the docker commands executed against it should return without error

# Possible Problems:
None
