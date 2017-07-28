# Reconfigure Virtual Container Hosts #

You can reconfigure certain settings on an existing virtual container host (VCH) by using the `vic-machine configure` command.

When you run `vic-machine configure`, you use the options described in [Common `vic-machine` Options](common_vic_options.md) to identify the VCH to configure. In addition to these options, the `vic-machine configure` command provides options that allow you to perform the following modifications on VCHs:

- [Update vCenter Server Credentials](#vccreds)
- [Add and Remove Volume Stores](#volumes)
- [Update TLS Certificates](#tlscerts)
- [Add and Remove DNS Servers](#dns)
- [Reconfigure Container Network Settings](#containernet)
- [Reconfigure Management Network Settings](#mgmtnet)
- [Reconfigure Client Network Settings](#clientnet)
- [Enable and Disable Debug Mode](#debug)
- [Add or Reconfigure Proxy Servers](#proxies)

To see the current configuration of a VCH before you reconfigure it, and to check the new configuration,  run `vic-machine inspect config` before and after you run `vic-machine configure`. For information about running `vic-machine inspect config`, see [Obtain VCH Configuration Information](inspect_vch_config.md).

In all cases, it is preferable to use the `--id` option rather than `--name` to 

## Update vCenter Server Credentials {#vccreds}

If the vCenter Server credentials with which VCHs run change, you must update those VCHs otherwise they will no longer function. 

If the password of the vCenter Server user account with which the VCH runs changes, provide the new password in in the `--ops-password` option. You use the `--ops-password` option to update the password even if the VCH uses the same vSphere administrator account for day-to-day operations as you use when you run `vic-machine` commands. For example, if you use Administrator@vsphere.local to run `vic-machine` commands, and you did not set the `--ops-user` option when you deployed the VCH, the VCH uses Administrator@vsphere.local for general operations. Consequently, to update the password, you specify the `vic-machine configure --user` option to log into the VCH, and the `--ops-user` and `--ops-password` options to update the password.  

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_address</i>
    --user Administrator@vsphere.local
    --password <i>password</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --ops-user Administrator@vsphere.local
    --ops-password <i>new_password</i></pre>

You can also configure the VCH to use a different user account than the vSphere administrator account for day-to-day operation

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>


   --user value, -u value                           ESX or vCenter user [%VIC_MACHINE_USER%]
   --password value, -p value                       ESX or vCenter password (default: <nil>) [%VIC_MACHINE_PASSWORD%]
   --thumbprint value                               ESX or vCenter host certificate thumbprint [%VIC_MACHINE_THUMBPRINT%]
--ops-user value                                 The user with which the VCH operates after creation. Defaults to the credential supplied with target (default: <nil>)
   --ops-password value                             Password or token for the operations user. Defaults to the credential supplied with target (default: <nil>)

## Update vCenter Server Certificates {#vccreds}

If the vCenter Server certificate changes, you must update any VCHs running on that vCenter Server instance, otherwise they will no longer function.

To update the certificate, provide the new certificate thumbprint in the `--thumbprint` option:

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --id <i>vch_id</i>
    --thumbprint <i>new_certificate_thumbprint</i>
    </pre>

## Add and Remove Volume Stores {#volumes}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--volume-store value, --vs value                 Specify a list of location and label for volume store, nfs stores can have mount options specified as query parameters in the url target.
                                                Examples for a vsphere backed volume store are:  "datastore/path:label" or "datastore:label" or "ds://my-datastore-name:store-label"
                                                     Examples for nfs back volume stores are: "nfs://127.0.0.1/path/to/share/point?uid=1234&gid=5678&proto=tcp:my-volume-store-label" or "nfs://my-store/path/to/share/point:my-label"

## Update TLS Certificates  {#tlscerts}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--tls-server-key value                           Virtual Container Host private key file (server certificate)
   --tls-server-cert value                          Virtual Container Host x509 certificate file (server certificate)
   --tls-cname value                                Common Name to use in generated CA certificate when requiring client certificate authentication
   --tls-cert-path value                            The path to check for existing certificates and in which to save generated certificates. Defaults to './<vch name>/'
   --no-tlsverify, --kv                             Disable authentication via client certificates - for more tls options see advanced help (-x)

## Add and Remove DNS Servers {#dns}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--dns-server value                               DNS server for the client, public, and management networks. Defaults to 8.8.8.8 and 8.8.4.4 when VCH uses static IP

## Reconfigure Container Network Settings {#containernet}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--container-network value, --cn value            vSphere network list that containers can use directly with labels, e.g. vsphere-net:backend. Defaults to DCHP - see advanced help (-x).
   --container-network-gateway value, --cng value   Gateway for the container network's subnet in CONTAINER-NETWORK:SUBNET format, e.g. vsphere-net:172.16.0.1/16
   --container-network-ip-range value, --cnr value  IP range for the container network in CONTAINER-NETWORK:IP-RANGE format, e.g. vsphere-net:172.16.0.0/24, vsphere-net:172.16.0.10-172.16.0.20
   --container-network-dns value, --cnd value       DNS servers for the container network in CONTAINER-NETWORK:DNS format, e.g. vsphere-net:8.8.8.8. Ignored if no static IP assigned.




## Enable and Disable Debug Mode  {#debug}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--debug value, -v value                          [0(default),1...n], 0 is disabled, 1 is enabled, >= 1 may alter behaviour (default: <nil>)

## Add or Reconfigure Proxy Servers {#proxies}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--https-proxy value                              An HTTPS proxy for use when fetching images, in the form https://fqdn_or_ip:port (default: <nil>)
   --http-proxy value                               An HTTP proxy for use when fetching images, in the form http://fqdn_or_ip:port (default: <nil>)

## Reconfigure CPU and Memory Allocations {#proxies}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--memory value, --mem value                      VCH resource pool memory limit in MB (unlimited=0) (default: <nil>)
   --memory-reservation value, --memr value         VCH resource pool memory reservation in MB (default: <nil>)
   --memory-shares value, --mems value              VCH resource pool memory shares in level or share number, e.g. high, normal, low, or 163840 (default: <nil>)
   --cpu value                                      VCH resource pool vCPUs limit in MHz (unlimited=0) (default: <nil>)
   --cpu-reservation value, --cpur value            VCH resource pool reservation in MHz (default: <nil>)
   --cpu-shares value, --cpus value                 VCH VCH resource pool vCPUs shares, in level or share number, e.g. high, normal, low, or 4000 (default: <nil>)


## Reconfigure --ops-user Account {#proxies}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>



## Add or Remove Registry Servers {#proxies}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

   --registry-ca value, --rc value                  Specify a list of additional certificate authority files to use to verify secure registry servers