# Logging In to the Management Portal #

You can access the Management Portal in a web browser by entering the vSphere Integrated Containers appliance IP address and the port that you specified for the portal during the deployment. By default the port number is *8282*.

If you do not know the port number, you can access the portal by going to http://<i>vic_appliance_address</i> and following the **Go to the vSphere Integrated Containers Management Portal** link.

To remove security warnings when you connect to the Getting Started page or management portal, see [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](../vic_vsphere_admin/obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](trust_vic_certs.md).

**Troubleshooting**

If you see a certificate error when you attempt to go to http://<i>vic_appliance_address</i>, see [Browser Rejects Certificates with `ERR_CERT_INVALID` Error](../vic_vsphere_admin/ts_cert_error.md).

If you are unable to log in to vSphere Integrated Containers Management Portal, see [Troubleshoot Post-Deployment Operation](ts_post_deployment_op.md). 

## Default User Access to the Management Portal ##

The role that has full permissions for vSphere Integrated Containers is the cloud administrator role. 
By default, the cloud administrator role is assigned to the Administrators group for vCenter Server during the installation of vSphere Integrated Containers. Every user that is a member of that group in the Platform Services Controller can access the Management Portal as cloud administrator. After you log in as a cloud administrator, you can give other users access to vSphere Integrated Containers by assigning them roles in projects.

Optionally, you can log in as one of the example users that were created during the OVA deployment, if you used that option. The example users allow you to see what each type of role can do in vSphere Integrated Containers Management Portal.

For more information about users and roles, see [vSphere Integrated Containers Roles and Personas](../vic_overview/roles_and_personas.md).
