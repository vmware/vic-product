Test 8-01 - Manual Upgrade
=======

# Purpose:
To verify the VIC OVA appliance works after upgrading from supported upgrade paths. 

# References:
[VIC appliance design
document](https://github.com/vmware/vic-product/blob/master/installer/docs/DESIGN.md)

# Environment:
This test requires access to VMWare Nimbus cluster for dynamic ESXi and vCenter creation

# Test Cases

## Upgrade from v1.2.1

### Test Steps:
1. Deploy, initialize, and populate the management portal and registry of a VIC appliance version 1.2.1
2. Deploy a current VIC appliance version 1.4.0 or greater. Do NOT power on.
3. Follow instructions for manually moving or copying `/data` disk and adding it to current
   appliance.
4. Power on the current appliance, but do NOT initialize it.
5. Run the appliance upgrade script with `--manual-disks` flag

### Expected Outcome:

- Upgrade script completed successfully
- Upgrade script migrated successfully (previously added elements are present in management portal
  and registry)


## Upgrade from v1.3.0 and v1.3.1

### Test Steps:
1. Deploy, initialize, and populate the management portal and registry of a VIC appliance version 1.3.0
2. Deploy a current VIC appliance version 1.4.0 or greater. Do NOT power on.
3. Follow instructions for manually moving or copying `/storage/data`, `/storage/log`, and
   `/storage/db` disks and adding them to current appliance.
4. Power on the current appliance, but do NOT initialize it.
5. Run the appliance upgrade script with `--manual-disks` flag

Repeat for VIC appliance version 1.3.1

### Expected Outcome:

- Upgrade script completed successfully
- Upgrade script migrated successfully (previously added elements are present in management portal
  and registry)
