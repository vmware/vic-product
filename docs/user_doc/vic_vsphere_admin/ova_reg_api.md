# Register the Appliance with the Platform Services Controller by Using the Registration API #

The vSphere Integrated Containers appliance provides an API that allows you to register the appliance with the Platform Services Controller without having to manually access the Getting Started page. This API helps you to automate the deployment of appliances without manual intervention.

The appliance exposes the registration API endpoint at http://<i>vic_appliance_address</i>:9443/register.

**Prerequistes**

You deployed an instance of the vSphere Integrated Containers appliance without completing the Platform Services Controller registration at http://<i>vic_appliance_address</i>.

**Procedure**

1. On your usual working system, create a file named `payload.json`, to include information about your vSphere environment.

    vCenter Server with an embedded Platform Services Controller:<pre>{
  "target":"<i>vcenter_server_address</i>",
  "user":"<i>sso_administrator_account</i>",
  "password":"<i>sso_administrator_password</i>"
}</pre>

    vCenter Server with an external Platform Services Controller:<pre>{
  "target":"<i>vcenter_server_address</i>",
  "user":"<i>sso_administrator_account</i>",
  "password":"<i>sso_administrator_password</i>,"
  "ExternalPSC":"psc_address",
  "PSCDomain":"psc_domain"
}</pre> 

2. Run a `curl` command to pass the `payload.json` file to the registration API endpoint.<pre>curl -k -w '%{http_code}' -d @payload.json https://<i>vic_appliance_address</i>:9443/register
</pre> 

**Result**

The appliance registers with the Platforms Services Controller. After registration, vSphere Integrated Containers services are available at  http://<i>vic_appliance_address</i>.