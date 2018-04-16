Test 5-8 - DRS
=======

# Purpose:
To verify the VIC appliance created using Wizard UI detects when DRS should be enabled and fuctions properly when used with DRS

# References:
[1 - VMware vCenter Server Availability Guide](http://www.vmware.com/files/pdf/techpaper/vmware-vcenter-server-availability-guide.pdf)

# Environment:
This test requires access to VMWare Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a new vCenter with 3 ESXi hosts in a cluster but with DRS disabled
2. Attempt to install a VCH appliance using wizard UI into the cluster
3. Enable DRS on the cluster
4. Re-attempt to install a VCH appliance using wizard UI into the cluster
5. Run a variety of docker commands on the VCH appliance

# Expected Outcome:
The first VCH appliance install should provide an error indicating that DRS must be enabled, the second VCH appliance install should deploy without error and each of the docker commands executed against it should return without error

# Possible Problems:
None
