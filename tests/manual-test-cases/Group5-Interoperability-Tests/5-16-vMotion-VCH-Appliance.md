Test 5-16 vMotion VCH Appliance
=======

# Purpose:
To verify the VCH appliance created using wizard continues to function properly after being vMotioned to a new host

# References:
[1- vMotion A Powered On Virtual Machine](http://pubs.vmware.com/vsphere-4-esx-vcenter/index.jsp?topic=/com.vmware.vsphere.dcadmin.doc_41/vsp_dc_admin_guide/migrating_virtual_machines/t_migrate_a_powered-on_virtual_machine_with_vmotion.html)

# Environment:
This test requires that a vCenter server is running and available

# Test Steps:
1. Deploy a new vCenter in Nimbus:  
   ```--testbedName vic-vsan-simple-pxeBoot-vcva```  
2. Install the VIC OVA appliance
3. Walk through completing the install and use the VCH creation wizard to create a VCH
4. Run Docker Regression Tests For VCH
5. vMotion the VCH appliance to a new host
6. Run a variety of docker commands on the VCH appliance after it has moved


# Expected Outcome:
The VCH and VIC appliance should deploy without error, VCH appliance should continue to work as expected after being vMotioned and all docker commands should return without error

# Possible Problems:
None
