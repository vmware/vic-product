# Logging In to the Management Portal #

The user role that has full permissions for vSphere Integrated Containers is the Management Portal administrator role. By default, the Management Portal administrator role is assigned to the Administrators group for vCenter Server during the installation of vSphere Integrated Containers. Every user that is a member of the vSphere administrators group in the Platform Services Controller can access the Management Portal as a Management Portal administrator. After you log in as a Management Portal administrator, you can give other users access to vSphere Integrated Containers by assigning them roles in projects.

Optionally, you can log in by using one of the example user accounts that were created during the OVA deployment, if you used that option. The example users allow you to see what each role can do in vSphere Integrated Containers Management Portal.

For more information about users and roles, see [vSphere Integrated Containers Roles and Personas](../vic_overview/roles_and_personas.md).

**Prerequisites**

- You or the vSphere administrator deployed and initialized the vSphere Integrated Containers appliance.
- You have a vCenter Server Single Sign-On user account with vSphere administrator privileges, or a user account that has been granted the Management Portal Administrator, DevOps administrator, developer, or viewer role in vSphere Integrated Containers.

**Procedure**

1. Enter the IP address or FQDN of the vSphere Integrated Containers appliance in a browser.

  -  https://<i>vic_appliance_address</i>
  -  https://<i>vic_appliance_address</i>:8282

    Always specify HTTPS in the URL. By default, the management portal is exposed on port 8282 of the vSphere Integrated Containers appliance. If the vSphere Integrated Containers appliance was configured to expose the management portal on a different port, replace 8282 with the appropriate port, or omit the port number.  

3. Enter vCenter Server Single Sign-On credentials for a vSphere administrator account or for a user account that has been granted a  role in vSphere Integrated Containers.

## Troubleshooting ##

To remove security warnings when you connect to the Getting Started page or management portal, see [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](../vic_vsphere_admin/obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](trust_vic_certs.md).

If you see a certificate error when you attempt to go to the vSphere Integrated Containers Getting Started page at https://<i>vic_appliance_address</i>:9443, see [Browser Rejects Certificates with `ERR_CERT_INVALID` Error](../vic_vsphere_admin/ts_cert_error.md).

If you are unable to log in to vSphere Integrated Containers Management Portal, see [Troubleshoot Post-Deployment Operation](../vic_vsphere_admin/ts_post_deployment_op.md). 