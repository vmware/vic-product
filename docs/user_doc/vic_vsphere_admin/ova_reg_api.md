# Initialize the Appliance by Using the Initialization API #

The vSphere Integrated Containers appliance provides an API that allows you to initialize the appliance after deployment without having to manually enter information in the Getting Started page. This API helps you to automate the deployment of appliances without manual intervention.

The appliance exposes the initialization API endpoint at https://<i>vic_appliance_address</i>:9443/register. If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, 9443 is replaced with the appropriate port.

**Prerequistes**

You deployed an instance of the vSphere Integrated Containers appliance without completing the Platform Services Controller registration wizard that appears when you first go to the vSphere Integrated Containers Getting Started page.

**Procedure**

1. On your usual working system, create a file named `payload.json`, to include information about your vSphere environment.

    vCenter Server with an embedded Platform Services Controller:<pre>{
  "target":"<i>vcenter_server_address</i>",
  "user":"<i>sso_administrator_account</i>",
  "password":"<i>sso_administrator_password</i>"
  "thumbprint":"<i>vc_thumbprint</i>"
}</pre>

    vCenter Server with an external Platform Services Controller:<pre>{
  "target":"<i>vcenter_server_address</i>",
  "user":"<i>sso_administrator_account</i>",
  "password":"<i>sso_administrator_password</i>",
  "thumbprint":"<i>vc_thumbprint</i>"
  "externalpsc":"psc_address",
  "pscdomain":"psc_domain"
}</pre> 

2. Run a `curl` command to pass the `payload.json` file to the initialization API endpoint.

    Copy the command as shown, replacing <i>vic_appliance_address</i> with the address of the appliance.<pre>curl -k -w '%{http_code}' -d @payload.json https://<i>vic_appliance_address</i>:9443/register
</pre>If successful, you see the message `operation complete
200`. 

**Result**

The appliance initializes and registers with the Platforms Services Controller. After initialization, vSphere Integrated Containers services are available at  https://<i>vic_appliance_address</i>:9443.

**Example**

Here is an example of a completed `payload.json` file: 

<pre>{
  "target":"vcenter-server1.mycompany.org",
  "user":"Administrator@vsphere.local",
  "password":"p@ssw0rd!",
  "thumbprint":"certificate_thumbprint",
  "externalpsc":"psc1.mycompany.org",
  "pscdomain":"vsphere.local"
}</pre> 