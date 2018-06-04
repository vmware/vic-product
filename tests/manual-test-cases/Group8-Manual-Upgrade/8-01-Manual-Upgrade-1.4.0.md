Test 8-01 - Manual Upgrade 1.4.0
=======

# Purpose:
To verify the VIC OVA appliance works after upgrading from 1.4.0

# References:
[VIC appliance design
document](https://github.com/vmware/vic-product/blob/master/installer/docs/DESIGN.md)

# Environment:
This test requires access to VMWare Nimbus cluster for dynamic ESXi and vCenter creation

# Test Cases

### Test Steps:
1. Deploy and initialize a VIC appliance version 1.4.0
2. Creat a VCH, running container and push an image to harbor
3. Deploy a current VIC appliance version 1.4.1 or greater. Do NOT power on.
4. Follow instructions for manually moving or copying `/storage/data`, `/storage/log`, and
   `/storage/db` disks and adding them to current appliance.
5. Power on the current appliance, but do NOT initialize it.
6. Run the appliance upgrade script with `--manual-disks` flag

### Expected Outcome:

- Upgrade script completed successfully
- Verify container created in step 2 is still available and running
- Verify image pushed in step 2 can be pulled from harbor
