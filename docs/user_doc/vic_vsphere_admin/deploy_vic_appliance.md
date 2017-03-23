# Deploy the vSphere Integrated Containers Appliance #

You install vSphere Integrated Containers by deploying a virtual appliance. The appliance runs vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal, and makes the download of the vSphere Integrated Containers Engine binaries available. 

**Prerequisites**

You downloaded the OVA installer from the [official vSphere Integrated Containers downloads page on vmware.com](http://www.vmware.com/go/download-vic).

**Procedure**

1. In the vSphere Web Client, right-click an object in the vCenter Server inventory, select **Deploy OVF template**, and navigate to OVA file.
2. Follow the installer prompts to perform basic configuration of the appliance and to select the vSphere resources for it to use. 

    - Accept or modify the appliance name
    - Destination datacenter or folder
    - Destination host, cluster, or resource pool
    - Accept the end user license agreements (EULA)
    - Disk format and destination datastore
    - Network that the appliance connects to

3. On the **Customize template** page, under **Appliance Security**, set the root password for the appliance VM and optionally uncheck the **Permit Root Login checkbox**. 

    Setting the root password for the appliance is mandatory.

4. Expand **Email Settings** and optionally configure an email account from which to send password reset emails.  

    If, after deployment, you configure vSphere Integrated Containers Registry to use LDAP authentication, the email settings are ignored.

5. Expand **Networking Properties** and optionally configure a static IP address for the appliance VM. 

    Leave the networking properties blank to use DHCP.

6. Expand **Harbor Configuration** to configure the deployment of vSphere Integrated Containers Registry. 

    - If you do not want to deploy vSphere Integrated Containers Registry, uncheck the **Deploy Harbor** check box.
    - In the **Harbor Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Registry service.
    - In the **Harbor Admin Password** text box, set the password for the vSphere Integrated Containers Registry admin account.
    - In the **Database Password** text box, set the password for the root user of the MySQL database that vSphere Integrated Containers Registry uses.
    - Optionally check the **Garbage Collection** check box to enable garbage collection when the appliance boots.
    - To use custom certificates to authenticate connections to vSphere Integrated Containers Registry, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates. 

7. Expand **Admiral Configuration** to configure the deployment of vSphere Integrated Containers Management Portal. 

    - If you do not want to deploy vSphere Integrated Containers Management Portal, uncheck the **Deploy Admiral** check box.
    - In the **Admiral Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Registry service.
    - To use custom certificates to authenticate connections to vSphere Integrated Containers Management Portal, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates.

8. Click **Next** and **Finish** to deploy the vSphere Integrated Containers appliance.

**Result**

When the deployment completes, the appliance makes the vSphere Integrated Containers services available:   
- vSphere Integrated Containers Registry: https://<i>vm_address</i>:443
- vSphere Integrated Containers Management Portal: https://<i>vm_address</i>:8282
- vSphere Integrated Containers Engine download: https://<i>vm_address</i>:<i>port</i>
- vSphere Integrated Containers client plug-in upload: https://<i>vm_address</i>:<i>port</i>

**What to Do Next** 

- Download the vSphere Integrated Containers Engine binaries
- Install the vSphere Client plug-ins
- Configure vSphere Integrated Containers Registry
- Configure vSphere Integrated Containers Registry

