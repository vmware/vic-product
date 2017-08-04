# Configure Virtual Container Hosts #

You can configure certain settings on an existing virtual container host (VCH) by using the `vic-machine configure` command.

When you run `vic-machine configure`, you use the options described in [Common `vic-machine` Options](common_vic_options.md) to identify the VCH to configure. In addition to these options, the `vic-machine configure` command provides options that allow you to perform the following modifications on VCHs:

- [Update vCenter Server Credentials](#vccreds)
- [Update vCenter Server Certificates](#vccert)
- [Add and Remove Volume Stores](#volumes)
- [Update TLS Certificates](#tlscerts)
- [Add and Remove DNS Servers](#dns)
- [Configure Container Network Settings](#containernet)
- [Enable and Disable Debug Mode](#debug)
- [Add, Configure, or Reset Proxy Servers](#proxies)

To see the current configuration of a VCH before you configure it, and to check the new configuration,  run `vic-machine inspect config` before and after you run `vic-machine configure`. For information about running `vic-machine inspect config`, see [Obtain VCH Configuration Information](inspect_vch_config.md).

## Update vCenter Server Credentials {#vccreds}

If the vCenter Server credentials change after the deployment of a VCH, you must update that VCH with the new credentials. The VCH will not function until you update the credentials. 

You provide the new vCenter Server credentials in the `vic-machine configure --ops-user` and `--ops-password` options. You use the `vic-machine configure --ops-user` and `--ops-password` options to update the credentials even if you did not specify the `vic-machine create --ops-user` and `--ops-password` options during the initial deployment of the VCH. If you did not specify `vic-machine create --ops-user` and `--ops-password` during the deployment of the VCH, by default the VCH uses the values from `vic-machine create --user` and `--password` for the `--ops-user` and `--ops-password` settings, and it uses these credentials for day-to-day, post-deployment operation. 

For example, if you specified `--user Administrator@vsphere.local` in the `vic-machine create` command, and you did not set the `vic-machine create --ops-user` and `--ops-password` options, the VCH automatically sets `--ops-user` to Administrator@vsphere.local and uses this account for post-deployment operations. Consequently, if the password for Administrator@vsphere.local changes, you must specify the `vic-machine configure --ops-user` and `--ops-password` options to update the password. This example specifies the `--user` and `--password` options to log into vCenter Server, and then specifies `--ops-user` and `--ops-password` to update those settings in the VCH. 

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_address</i>
    --user Administrator@vsphere.local
    --password <i>password</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --ops-user Administrator@vsphere.local
    --ops-password <i>new_password</i></pre>

You can also use the `vic-machine configure --ops-user` and `--ops-password` options to configure an operations user on a VCH that was not initially deployed with that option. Similarly, you can use `--ops-user` and `--ops-password` to change the operations user account on a VCH that was deployed with an operations user account, or to update the password for a previously specified operations user account. This example specifies the credentials to log into vCenter Server in the `--target` option, rather than in `--user` and `--password`.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --ops-user <i>new_operations_user_account</i>
    --ops-password <i>password</i></pre>

## Update vCenter Server Certificates {#vccert}

If the vCenter Server certificate changes, you must update any VCHs running on that vCenter Server instance, otherwise they will no longer function.

To update the certificate, provide the new certificate thumbprint to the VCH in the `--thumbprint` option:

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --id <i>vch_id</i>
    --thumbprint <i>new_certificate_thumbprint</i></pre>

**NOTE**: If you run `vic-machine configure` with the `--force` option and you do not specify `--thumbprint`, `vic-machine` updates the thumbprint automatically.

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

## Configure Container Network Settings {#containernet}

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

## Add, Configure, or Reset Proxy Servers {#proxies}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--https-proxy value                              An HTTPS proxy for use when fetching images, in the form https://fqdn_or_ip:port (default: <nil>)
   --http-proxy value                               An HTTP proxy for use when fetching images, in the form http://fqdn_or_ip:port (default: <nil>)

## Configure CPU and Memory Allocations {#proxies}

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


## Add or Remove Registry Servers {#proxies}

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

   --registry-ca value, --rc value                  Specify a list of additional certificate authority files to use to verify secure registry servers