# vSphere Integrated Containers Appliance Fails to Register with PSC #

The vSphere Integrated Containers appliance deploys successfully, but the initialization of the appliance fails.

## Problem ##

When you enter the vCenter Server credentials at the login prompt on the vSphere Integrated Containers Getting Started page, you see a red alert with the message `Failed to register with PSC. Please check the vSphere user domain PSC settings and try again`. 

## Cause ##

- You are deploying vSphere Integrated Containers 1.2.0.
- Your vSphere environment uses an external Platform Services Controller instance that is not embedded in the vCenter Server instance to which you deployed the appliance. 

## Solution ##

If you are performing a fresh installation of vSphere Integrated Containers, download and deploy version 1.2.1 or later. vSphere Integrated Containers 1.2.1 allows you to register the appliance with an external Platform Services Controller.

If an attempt to upgrade vSphere Integrated Containers 1.1.x to version 1.2.0 failed because vCenter Server is managed by an external Platform Services Controller, perform the following procedure. 

1. Use SSH to connect to the appliance VM as `root` user, using the password that you specified during the OVA deployment.

    <pre>ssh root@<i>vic_appliance_address</i></pre>
2. Run a command to register vSphere Integrated Containers Registry with the external Platform Services Controller. 

    Specify `harbor` in the `--clientName` parameter and set the following parameters according to your vSphere environment:

    * `--tenant`: The user domain, for example, `vsphere.local`.
    * `--username`: A vCenter Server user name with administrator privileges, for example,  `administrator@vsphere.local`.
    * `--password`: The password for the vCenter Server user account, formatted appropriately to escape special characters in the shell
    * `--domainController`: The FQDN of the Platform Service Controller instance. If the Platform Service Controller instance is hosted on the vCenter Server host, for example `https://$vCenterFQDN/psc`, the value for this parameter should just be the FQDN of the vCenter host.
    * `--admiralUrl`: The address of vSphere Integrated Containers Management Portal, for example `https://vic_appliance_IP:8282`.
    * `--defaultUserPrefix`: (Optional) The prefix for the user names of the example users. If you did not change this during OVA deployment, the default is `vic`. If you specify `--defaultUserPrefix` you must also specify `--defaultUserPassword`.
    * `--defaultUserPassword`: (Optional) The password for the example users. The password must follow the rules set for vSphere. If you did not change this during OVA deployment, the default is `VicPro!23`. If you specify `--defaultUserPassword` you must also specify `--defaultUserPrefix`.

    In the following example, parameters that you must update are highlighted in **bold**. Copy the other parameters as they are shown in the example.

    <pre>java -jar /etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar
     --command=register 
     --version=6.0 
     --configDir=/etc/vmware/psc 
     <b>--clientName=harbor
     --tenant=<i>yourdomain</i>
     --username=<i>administrator@yourdomain</i>
     --password='<i>p@ssw0rd</i>'
     --domainController=<i>psc_fqdn</i>
     --admiralUrl=https://<i>vic_appliance_IP</i>:8282
     --defaultUserPrefix=vic
     --defaultUserPassword='VicPro!23'</b>
</pre>

3. Run the command again to register vSphere Integrated Containers Engine.  

    Change the `--clientName` parameter to `engine`. Specify all of the other parameters with the same values as you used in the previous step.

    <pre>java -jar /etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar
     --command=register 
     --version=6.0 
     --configDir=/etc/vmware/psc 
     <b>--clientName=engine</b>
     --tenant=<i>yourdomain</i>
     --username=<i>administrator@yourdomain</i>
     --password='<i>p@ssw0rd</i>'
     --domainController=<i>psc_fqdn</i>
     --admiralUrl=https://<i>vic_appliance_IP</i>:8282
     --defaultUserPrefix=vic
     --defaultUserPassword='VicPro!23'
</pre>

4. Run the command a third time to register vSphere Integrated Containers Management Portal. 

    Change the `--clientName` parameter to `admiral`. Specify all of the other parameters with the same values as you used in the previous two steps.

    <pre>java -jar /etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar
     --command=register 
     --version=6.0 
     --configDir=/etc/vmware/psc 
     <b>--clientName=admiral</b>
     --tenant=<i>yourdomain</i>
     --username=<i>administrator@yourdomain</i>
     --password='<i>p@ssw0rd</i>'
     --domainController=<i>psc_fqdn</i>
     --admiralUrl=https://<i>vic_appliance_IP</i>:8282
     --defaultUserPrefix=vic
     --defaultUserPassword='VicPro!23'
</pre>

5. After you have run the command 3 times, run the following command.

    <pre>touch /registration-timestamps.txt</pre>

    This command prevents the login window from reappearing on subsequent visits to the Getting Started page.

**Result** 

The appliance is registered with the external Platform Services Controller and the vSphere Integrated Containers services are available at https://<i>vic_appliance_address</i>:8282.

