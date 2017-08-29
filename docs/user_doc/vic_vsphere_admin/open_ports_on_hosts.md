# Open the Required Ports on ESXi Hosts #

ESXi hosts communicate with the virtual container hosts (VCHs) through port 2377 via Serial Over LAN. For the deployment of a VCH to succeed, port 2377 must be open for outgoing connections on all ESXi hosts before you run `vic-machine create` to deploy a VCH. Opening port 2377 for outgoing connections on ESXi hosts opens port 2377 for inbound connections on the VCHs.

The `vic-machine` utility includes an `update firewall` command, that you can use to modify the firewall on a standalone ESXi host or all of the ESXi hosts in a cluster. 

You use the `--allow` and `--deny` flags to enable and disable a firewall rule named `vSPC`. When enabled, the `vSPC` rule allows all outbound TCP traffic from the target host or hosts. If you disable the rule, you must configure the firewall via another method to allow outbound connections on port 2377 over TCP. If you do not enable the rule or configure the firewall, vSphere Integrated Containers Engine does not function, and you cannot deploy VCHs.

The `vic-machine create` command does not modify the firewall. Run `vic-machine update firewall --allow` before you run `vic-machine create`.

**Prerequisites**

* Deploy the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
* In a Web browser, go to  http://<i>vic_appliance_address</i>, scroll down to Infrastructure Deployment Tools, click the link to **download the vSphere Integrated Containers Engine bundle**, and unpack it on your working machine.  
**Procedure**

1. Open a terminal on the system on which you downloaded and unpacked the vSphere Integrated Containers Engine binary bundle.
2. Navigate to the directory that contains the `vic-machine` utility:
3. Run the `vic-machine update firewall` command.

    To open the appropriate ports on all of the hosts in a vCenter Server cluster, run the following command: 

      <pre>$ vic-machine-<i>operating_system</i> update firewall
--target <i>vcenter_server_address</i>
--user "Administrator@vsphere.local"
--password <i>vcenter_server_password</i>
--compute-resource <i>cluster_name</i>
--thumbprint <i>thumbprint</i> 
--allow</pre>

    To open the appropriate ports on an ESXi host that is not managed by vCenter Server, run the following command: 

      <pre>$ vic-machine-<i>operating_system</i> update firewall
--target <i>esxi_host_address</i>
--user root
--password <i>esxi_host_password</i>
--thumbprint <i>thumbprint</i> 
--allow</pre>


The `vic-machine update firewall` command in these examples specifies the following information:

- The address of the vCenter Server instance and datacenter, or the ESXi host, on which to deploy the VCH in the `--target` option.  
- The user name and password for the vCenter Server instance or ESXi host in the `--user` and `--password` options. 
- In the case of a vCenter Server cluster, the name of the cluster in the `--compute-resource` option.
- The thumbprint of the vCenter Server or ESXi host certificate in the `--thumbprint` option, if they use untrusted, self-signed certificates. 

     Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.
- The `--allow` option to open the port.