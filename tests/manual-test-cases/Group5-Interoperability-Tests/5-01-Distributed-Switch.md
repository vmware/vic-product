Test 5-01 - Distributed Switch
=======

# Purpose:
To verify the VIC OVA appliance works in a variety of different vCenter networking configurations

# References:
[1 - VMware Distributed Switch Feature](https://www.vmware.com/products/vsphere/features/distributed-switch.html)

# Environment:
This test requires access to VMWare Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a new vCenter in Nimbus that is a simple VC with a distributed switch
2. Install the VIC OVA appliance
3. Walk through completing the install and use the VCH creation wizard to create a VCH
4. Run a variety of docker commands on the VCH appliance

# Expected Outcome:
The VCH OVA appliance should deploy without error and each of the docker commands executed against it should return without error

# Possible Problems:
* When you add an ESXi host to the vCenter it will overwrite its datastore name from datastore1 to datastore1 (n)
* govc requires an actual password so you need to change the default ESXi password before Step 4
* govc doesn't seem to be able to force a host NIC over to the new distributed switch, thus you need to create the ESXi hosts with 2 NICs in order to use the 2nd NIC for the distributed switch
