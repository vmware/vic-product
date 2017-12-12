# Uninstall vSphere Integrated Containers

The process of uninstalling vSphere Integrated Containers depends on the way that you use the product. In general, you stop the running containers, delete the VCHs that you deployed, and delete the vSphere Integrated Containers virtual appliance. If you perform the three operations, no significant footprint stays in your environment. To make sure that no vSphere Integrated Containers elements persist, also unregister the vSphere Integrated Containers plug-ins and delete the product-specific users from your Platform Services Controller.

**Procedure**

1. Stop any running containers on your VCHs.
2. Delete all VCHs in your environment.

	For information about the `vic-machine delete` command, see [Delete Virtual Container Hosts](./remove_vch.md)

3. Delete any vSphere Integrated Containers virtual appliances that you deployed.

	For information about removing VMs from the datastore, see [Remove Virtual Machines from the Datastore](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vm_admin.doc/GUID-40736044-E1F7-48FB-928E-6B00AEF2F1BD.html) in the vSphere 6.5 documentation.

4. Unregister the vSphere Integrated Containers plug-ins from vCenter Server by using the Managed Object Browser.
	1. Log in to https://<i>vCenter_Server_address</i>/mob/?moid=ExtensionManager with vCenter Server administrator credentials.
	2. In ExtensionManager, click **unregisterExtension**.
	3. Enter `com.vmware.vic.ui` for the extension key value, and click **Invoke Method**.
	4. Verify that the result displays `void` and not an error message.

	An error message might appear if the specified extension is not registered, or if an unexpected runtime error occurs.

	5. Enter `com.vmware.vic` for the extension key value, and click **Invoke Method**.
	6. Verify that the result displays `void` and not an error message.
	7. Close the window.
	8. Refresh the ExtensionManager page and verify that the extensionList entry does not include any `com.vmware.vic` related entries.
5. Clean up any vSphere Integrated Containers related users from your Platform Services Controller.
	1. Log in to https://<i>Platform_Services_Controller_address</i>/psc with vCenter Server administrator credentials.
	2. If you created default users for your vSphere Integrated Containers instance, click **Users and Groups**, select the *Cloud Admin* user, the *DevOps Admin* user, and the *Developer* user, and click **Delete** for each of them.
	3. Click the **Solution Users** tab, select the users that start with *engine*, *admiral*, and *harbor*, and click **Delete** for each of them.
6. Verify that no vSphere Integrated Containers VMDK files are left on your datastore.
