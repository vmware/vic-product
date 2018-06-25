# Obtain General Virtual Container Host Information and Connection Details #

You can obtain general information about a virtual container host (VCH) and its connection details by using the `vic-machine inspect` command.

In addition to the common options described in [Common `vic-machine` Options](common_vic_options.md), the `vic-machine inspect` command only includes one option, `--tls-cert-path`. 

  - You must specify the user name and optionally the password, either in the `--target` option or separately in the `--user` and `--password` options. 
  - If the VCH has a name other than the default name, `virtual-container-host`, you must specify the `--name` or `--id` option. 
  - If multiple compute resources exist in the datacenter, you must specify the `--compute-resource` or `--id` option. 
  -  If your vSphere environment uses untrusted, self-signed certificates, you must specify the thumbprint of the vCenter Server instance or ESXi host in the `--thumbprint` option. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md). 

     Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.
  
  - If the VCH implements server and client authentication (`tlsverify`) and uses a non-default location to store its certificates, specify the `--tls-cert-path` option. If you do not specify `--tls-cert-path`, `vic-machine inspect` looks for valid certificates in `$PWD`, `$PWD/$vch_name` and `$HOME/.docker`. 

## Examples ##

The following example includes the options required to obtain information about a named instance of a VCH from a simple vCenter Server environment. 

<pre>$ vic-machine-<i>operating_system</i> inspect
    --target <i>vcenter_server_address</i>
    --user Administrator@vsphere.local
    --password <i>password</i>
    --thumbprint <i>certificate_thumbprint</i>
    --name <i>vch_name</i>
</pre>

The following example includes the `--tls-cert-path` option, for a VCH that stores client certificates in a non-default location.

<pre>$ vic-machine-<i>operating_system</i> inspect
    --target <i>vcenter_server_address</i>
    --user Administrator@vsphere.local
    --password <i>password</i>
    --thumbprint <i>certificate_thumbprint</i>
    --name <i>vch_name</i>
    --tls-cert-path <i>path_to_certificates</i>
</pre>

### Output

The `vic-machine inspect` command displays general information about the VCH, its version and upgrade status, and details about how to connect to the VCH:

- The VCH ID:<pre>VCH ID: VirtualMachine:vm-101</pre> The vSphere Managed Object Reference, or moref, of the VCH. You can use the VCH ID when you run the `vic-machine delete`, `configure`, or `debug` commands. Using a VCH ID reduces the number of options that you need to specify when you run those commands.
- The version of the `vic-machine` utility and the version of the VCH that you are inspecting.<pre>Installer version: <i>vic_machine_version</i>-<i>vic_machine_build</i>-<i>git_commit</i>
VCH version: <i>vch_version</i>-<i>vch_build</i>-<i>git_commit</i></pre>

- The upgrade status of the VCH:<pre>VCH upgrade status: 
Installer has same version as VCH
No upgrade available with this installer version</pre>
  If `vic-machine inspect` reports a difference between the version or build number of `vic-machine` and the version or build number of the VCH, the upgrade status is `Upgrade available`. 

- The address of the VCH Admin portal for the VCH.<pre>VCH Admin Portal:
https://<i>vch_address</i>:2378</pre>

- The address at which the VCH publishes ports.<pre><i>vch_address</i></pre>
- The Docker environment variables that container developers can use when connecting to this VCH, depending on the the level of security that the VCH implements.
  - VCH with server and client authentication (`tlsverify`):<pre>DOCKER_TLS_VERIFY=1 
DOCKER_CERT_PATH=<i>path_to_certificates</i>
DOCKER_HOST=<i>vch_address</i>:2376</pre>If `vic-machine inspect` is unable to find the appropriate client certificates, either in the default location or in a location that you specify in the `--tls-cert-path` option, the output includes a warning.<pre>Unable to find valid client certs
DOCKER_CERT_PATH must be provided in environment or certificates specified individually via CLI arguments</pre>
  - VCH with TLS server authentication but without client authentication (`no-tlsverify`):<pre>DOCKER_HOST=<i>vch_address</i>:2376</pre>
  - VCH with no TLS authentication (`no-tls`):<pre>DOCKER_HOST=<i>vch_address</i>:2375</pre>
- The Docker command to use to connect to the Docker endpoint, depending on the the level of security that the VCH implements.
  - VCH with server and client authentication (`tlsverify`):<pre>docker -H <i>vch_address</i>:2376 --tlsverify info</pre>
  - VCH with TLS server authentication but without client authentication (`no-tlsverify`):<pre>docker -H <i>vch_address</i>:2376 --tls info</pre>
  - VCH with no TLS authentication  (`no-tls`):<pre>docker -H <i>vch_address</i>:2375 info</pre>