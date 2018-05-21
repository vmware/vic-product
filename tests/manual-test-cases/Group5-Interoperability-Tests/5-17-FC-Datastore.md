Test 5-17 - FC Datastore
=======

# Purpose:
To verify that VIC OVA and Wizard UI works properly when installed on an Fibre Channel based datastore

# References:
[1 - Add Fibre Channel Storage](https://pubs.vmware.com/vsphere-4-esx-vcenter/index.jsp?topic=/com.vmware.vsphere.server_configclassic.doc_41/esx_server_config/configuring_storage/t_add_fibre_channel_storage.html)

# Environment:
This test requires access to VMware Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a new vCenter with a simple cluster
2. Deploy an FC server
3. Create a new datastore out of an FC lun on the FC server
4. Install the VIC OVA appliance into the cluster using the new FC based datastore
5. Walk through completing the install and use the VCH creation wizard to create a VCH
6. Run Docker Regression Tests For VCH

# Expected Outcome:
The VCH and VIC appliance should deploy without error and each of the docker commands executed against it should return without error

# Possible Problems:
* None
