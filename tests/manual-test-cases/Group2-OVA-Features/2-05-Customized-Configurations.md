Test 2-05 - Customized Configurations
=======

# Purpose:
To verify the VIC OVA appliance works as expected when deployed with customized configuration: static IP, ntp, proxy, remote syslog

# References:

# Environment:
This test requires access to VMware Nimbus cluster for dynamic ESXi and vCenter creation

# Test Steps:
1. Deploy a simple vCenter with cluster
2. Install the VIC OVA appliance using static IP, ntp, proxy, remote syslog.
3. SSH to the appliance and check /etc/systemd/network/09-vic.network, ip addr, ip route show, resolv.conf.
4. SSH to the appliance and check ntp service.
5. SSH to the appliance and check proxy configurations for Admiral and Harbor.
6. SSH to remote syslog server and check logs received.

# Expected Outcome:
Step 2 should pass without error and step 3-6 checks should be as expected.

# Possible Problems:
None
