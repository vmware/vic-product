Test 2-05 - Static IP
=======

# Purpose:
To verify the VIC OVA appliance works as expected when deployed using static IP

# References:

# Environment:
This test requires access to VMware Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a simple vCenter with cluster
2. Install the VIC OVA appliance using static IP
3. SSH to the appliance and check /etc/systemd/network/09-vic.network, ip addr, ip route show, resolv.conf

# Expected Outcome:
Step 2 should pass without error and step 3 checks should be as expected.

# Possible Problems:
None
