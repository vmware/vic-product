# VCH Deployment Fails with Firewall Validation Error #
When you use `vic-machine create` to deploy a virtual container host (VCH), deployment fails because firewall port 2377 is not open on the target ESXi host or hosts.

## Problem ##
Deployment fails with a firewall error during the validation phase: 

<pre>Firewall must permit dst 2377/tcp outbound to the VCH management interface</pre>

## Cause ##

ESXi hosts communicate with the VCHs through port 2377 via Serial Over LAN. For deployment of a VCH to succeed, port 2377 must be open for outgoing connections on all ESXi hosts before you run `vic-machine create`. Opening port 2377 for outgoing connections on ESXi hosts opens port 2377 for inbound connections on the VCHs.

## Solution ##

The `vic-machine` utility includes an `update firewall` command, that you can use to modify the firewall on the ESXi host or the ESXi hosts in a cluster. 

You use `--allow` and `--deny` flags to enable and disable the `vSPC` ruleset. When enabled, the `vSPC` rule allows all outbound TCP traffic from the target host or hosts. If you disable the rule, you must configure the firewall via another method to allow outbound connections on port 2377 over TCP. If you do not enable the rule or configure the firewall, vSphere Integrated Containers does not function, and you cannot deploy VCHs.

Neither of the `vic-machine create` or `vic-machine delete` commands modify the firewall. You can run `vic-machine update firewall --allow` before you run `vic-machine create` and run `vic-machine update firewall --deny` after `vic-machine delete`. 

<pre>vic-machine-windows update firewall 
--target 'Administrator@vsphere.local':'<i>password</i>'@<i>vcenter_server_address</i>/dc1 
--compute-resource cluster1
--thumbprint <i>thumbprint</i> 
--allow
</pre>

<pre>vic-machine-windows update firewall 
--target 'Administrator@vsphere.local':'<i>password</i>'@<i>vcenter_server_address</i>/dc1 
--compute-resource cluster1
--thumbprint <i>thumbprint</i> 
--deny
</pre>

