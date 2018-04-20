# VCH Deployment Fails with Firewall Validation Error #
When you deploy a virtual container host (VCH), deployment fails because firewall port 2377 is not open on the target ESXi host or hosts.

## Problem ##
Deployment fails with a firewall error during the validation phase: 

<pre>Firewall must permit dst 2377/tcp outbound to the VCH management interface</pre>

## Cause ##

ESXi hosts communicate with the VCHs through port 2377 via Serial Over LAN. For deployment of a VCH to succeed, port 2377 must be open for outgoing connections on all ESXi hosts before you run `vic-machine create`. Opening port 2377 for outgoing connections on ESXi hosts opens port 2377 for inbound connections on the VCHs.

## Solution ##

The `vic-machine` utility includes an `update firewall` command, that you can use to modify the firewall on the ESXi host or the ESXi hosts in a cluster. For information about how to use the `update firewall` command, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).