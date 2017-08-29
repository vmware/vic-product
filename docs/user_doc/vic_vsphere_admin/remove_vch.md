# Delete Virtual Container Hosts #

You delete virtual container hosts (VCHs) by using the `vic-machine delete` command.

The `vic-machine delete` includes one option in addition to the [Common `vic-machine` Options](common_vic_options.md), `--force`.

- You must specify the username and optionally the password, either in the `--target` option or separately in the `--user` and `--password` options. 
- If the VCH has a name other than the default name, `virtual-container-host`, you must specify the `--name` or `--id` option. 
- If multiple compute resources exist in the datacenter, you must specify the `--compute-resource` or `--id` option.
- Specifying the `--force` option forces `vic-machine delete` to ignore warnings and continue with the deletion of a VCH. Any running container VMs and any volume stores associated with the VCH are deleted. Errors such as an incorrect compute resource still cause the deletion to fail. 

  - If you do not specify `--force` and the VCH contains running container VMs, the deletion fails with a warning. 
  - If you do not specify `--force` and the VCH has volume stores, the deletion of the VCH succeeds without deleting the volume stores. The list of volume stores appears in the `vic-machine delete` success message for reference and optional manual removal.
- If your vSphere environment uses untrusted, self-signed certificates, you must specify the thumbprint of the vCenter Server instance or ESXi host in the `--thumbprint` option. For information about how to obtain the certificate thumbprint, see [Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host](obtain_thumbprint.md). 

     **NOTE**: Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.

When you delete a VCH that uses TLS authentication with trusted Certificate Authority (CA) certificates, `vic-machine delete` does not delete the certificates or the certificate folder, even if you specify the `--force` option. Because `vic-machine delete` does not delete the certificates, you can delete VCHs and create new ones that reuse the same certificates. This is useful if you have already distributed the client certificates for VCHs that you need to recreate.

The `vic-machine delete` command does not modify the firewall on ESXi hosts. If you do not need to deploy or run further VCHs on the ESXi host or cluster after you have deleted VCHs, run `vic-machine update firewall --deny` to close port 2377 on the host or hosts. 

## Example ##

The following example includes the options required to remove a VCH from a simple vCenter Server environment. 

  <pre>$ vic-machine-<i>operating_system</i> delete
--target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
--thumbprint <i>certificate_thumbprint</i>
--name <i>vch_name</i></pre>

If the delete operation fails with a message about container VMs that are powered on, run `docker stop` on the containers and run `vic-machine delete` again. Alternatively, run `vic-machine delete` with the `--force` option.

**CAUTION** Running `vic-machine delete` with the `--force` option removes all running container VMs that the VCH manages, as well as any associated volumes and volume stores. It is not recommended to use the `--force` option to remove running containers.

<pre>$ vic-machine-<i>operating_system</i> delete
--target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
--thumbprint <i>certificate_thumbprint</i>
--name <i>vch_name</i>
--force</pre>

If your vSphere environment uses untrusted, self-signed certificates, running `vic-machine delete` with the `--force` option allows you to omit the `--thumbprint` option.  

**CAUTION**: It is not recommended to use `--force` to bypass thumbprint verification in production environments.  Using `--force` in this way exposes VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. 

<pre>$ vic-machine-<i>operating_system</i> delete
--target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
--name <i>vch_name</i></i>
--force</pre>