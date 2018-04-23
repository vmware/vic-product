Test 5-15 - NFS Datastore
=======

# Purpose:
To verify that VIC OVA and Wizard UI works properly when installed on an NFS based datastore

# References:
[1 - Best practices for running VMware vSphere on NFS](http://www.vmware.com/content/dam/digitalmarketing/vmware/en/pdf/techpaper/vmware-nfs-bestpractices-white-paper-en.pdf)

# Environment:
This test requires access to VMware Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a new vCenter with a simple cluster
2. Deploy an NFS server
3. Create a new datastore out of a NFS share on the NFS server
4. Install the VIC OVA appliance
5. Walk through completing the install and use the VCH creation wizard to create a VCH
6. Run a variety of docker commands on the VCH appliance

# Expected Outcome:
The VCH and VIC appliance should deploy without error and each of the docker commands executed against it should return without error

# Possible Problems:
None
