# Authorize SSH Access to the VCH Endpoint VM #

You can use the `vic-machine debug` command to enable shell access to a virtual container host (VCH) endpoint VM by setting a root password on the VM. Setting a root password enables access to the VCH endpoint VM via the VM console. If you authorize SSH access to the VCH endpoint VM, you can edit system configuration files that you cannot edit by running `vic-machine` commands. You can also use `debug` to authorize SSH access to the VCH endpoint VM. You can optionally upload a key file for public key authentication when accessing the endpoint VM by using SSH. 

**IMPORTANT**: Any changes that you make to a VCH by using `vic-machine debug` are non-persistent and are discarded if the VCH endpoint VM reboots.

- You must specify the vSphere target and its credentials, either in the `--target` option or separately in the `--user` and `--password` options. 
      
    The credentials that you provide must have the following privilege on the endpoint VM:<pre>Virtual machine.Guest Operations.Guest Operation Program Execution</pre>
- You must specify the ID or name of the VCH to debug.
- You might need to provide the thumbprint of the vCenter Server or ESXi host certificate. Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.
- To enable SSH access, you mush enable shell access by specifying the `--rootpw` option. Wrap the password in single quotes (Linux or Mac OS) or double quotes (Windows) if it includes shell characters such as `$`, `!` or `%`.
- You authorize SSH access by specifying `--enable-ssh`. The `sshd` service runs until the VCH endpoint VM reboots. The `--enable-ssh` option takes no arguments. 
- If you have already enabled SSH access but the password that you set has expired, and you then rerun `--enable-ssh` without specifying `--rootpw`, the password expiry is set to 1 day in the future and the password is preserved.
- Optionally, you can specify the `--authorized-key` option to upload a public key file to `/root/.ssh/authorized_keys` folder in the endpoint VM. Include the name of the `*.pub` file in the path. <pre>--authorized-key <i>path_to_public_key_file</i>/<i>key_file</i>.pub</pre>


## Example ##

This example authorizes SSH access and provides a public key file.

<pre>$ vic-machine-<i>operating_system</i> debug
     --target <i>vcenter_server_or_esxi_host_address</i>
     --user <i>vcenter_server_or_esxi_host_username</i>
     --password <i>vcenter_server_or_esxi_host_password</i>
     --id <i>vch_id</i>
     --thumbprint <i>certificate_thumbprint</i>
     --enable-ssh
     --rootpw '<i>new_p@ssword</i>' 
     --authorized-key <i>path_to_public_key_file</i>/<i>key_file</i>.pub</pre>
  
### Output

The output of the `vic-machine debug` command includes confirmation that SSH access is enabled:

<pre>### Configuring VCH for debug ####
[...]
SSH to appliance:
ssh root@<i>vch_address</i>
[...]
Completed successfully</pre>   