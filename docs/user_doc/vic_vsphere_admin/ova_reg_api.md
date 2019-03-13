# Register the Appliance by Using the Registration API #

The vSphere Integrated Containers appliance provides an API that, after deployment, allows you to register the appliance with vCenter Server without having to manually enter information in the appliance welcome page. This API helps you to automate the deployment of appliances without manual intervention.

The appliance exposes the registration API endpoint at https://<i>vic_appliance_address</i>:9443/register. If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, 9443 is replaced with the appropriate port.

## Prerequisites

You deployed an instance of the vSphere Integrated Containers appliance without completing the registration wizard that appears in the **Complete VIC appliance installation** panel when you first go to the vSphere Integrated Containers appliance welcome page.

## Procedure

1. On your usual working system, create a file named `payload.json`, to include information about your vSphere environment.

    vCenter Server with an embedded Platform Services Controller:<pre>{
  "target":"<i>vcenter_server_address</i>",
  "user":"<i>sso_administrator_account</i>",
  "password":"<i>vcenter_sso_administrator_password</i>",
  "thumbprint":"<i>vc_thumbprint</i>",
  "vicpassword":"<i>vic_appliance_root_password</i>"
}</pre>

    vCenter Server with an external Platform Services Controller:<pre>{
  "target":"<i>vcenter_server_address</i>",
  "user":"<i>sso_administrator_account</i>",
  "password":"<i>vcenter_sso_administrator_password</i>",
  "thumbprint":"<i>vc_thumbprint</i>",
  "externalpsc":"psc_address",
  "pscdomain":"psc_domain",
  "vicpassword":"<i>vic_appliance_root_password</i>"
}</pre> 

    **NOTE**: The registration API does not include an option to skip the installation or upgrade of the vSphere Integrated Containers plug-in for the vSphere Client.

2. Run a `curl` command to pass the `payload.json` file to the initialization API endpoint.

    Copy the command as shown, replacing <i>vic_appliance_address</i> with the address of the appliance.<pre>curl -k -w '%{http_code}' -d @payload.json https://<i>vic_appliance_address</i>:9443/register
</pre>If successful, you see the message `operation complete
200`. If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, replace 9443 with the appropriate port.

## Result

The appliance registers with the Platforms Services Controller. After registration, vSphere Integrated Containers services are available at  https://<i>vic_appliance_address</i>:9443.

## Example

Here is an example of a completed `payload.json` file: 

<pre>{
  "target":"vcenter-server1.mycompany.org",
  "user":"Administrator@vsphere.local",
  "password":"p@ssw0rd!",
  "thumbprint":"12:34:F3:B2:85:2F:F7:95:B3:1E:99:F4:FB:28:4E:E7:5E:E0:5B:33",
  "externalpsc":"psc1.mycompany.org",
  "pscdomain":"vsphere.local",
  "vicpassword":"<i>vic_appliance_root_password</i>"
}</pre> 