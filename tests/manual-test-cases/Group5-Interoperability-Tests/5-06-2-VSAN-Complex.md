Test 5-06-2 - VSAN-Complex
=======

# Purpose:
To verify the VIC OVA appliance and Wizard UI works with VMware Virtual SAN

# References:
[1 - VMware Virtual SAN](http://www.vmware.com/products/virtual-san.html)

# Environment:
This test requires access to VMWare Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a complex test bed in Nimbus:  
```--testbedName test-vpx-4esx-virtual-fullInstall-vcva-8gbmem```
2. Install the VIC OVA appliance
3. Walk through completing the install and use the VCH creation wizard to create a VCH
4. Run Docker Regression Tests For VCH

# Expected Outcome:
The VCH and VIC appliance should deploy without error and each of the docker commands executed against it should return without error

# Possible Problems:
* None
