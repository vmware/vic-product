# Enable shell access to the VCH Endpoint VM #

You can use the `vic-machine debug` command to enable shell access to a virtual container host (VCH) endpoint VM by setting a root password on the VM. Setting a root password enables access to the VCH endpoint VM via the VM console only. If you require SSH access to the VCH endoint VM, rather than just shell access, see [Authorize SSH Access to the VCH Endpoint VM](vch_ssh_access.md).  

**IMPORTANT**: Any changes that you make to a VCH by using `vic-machine debug` are non-persistent and are discarded if the VCH endpoint VM reboots.

In addition to the [Common `vic-machine` Options](common_vic_options.md), `vic-machine debug` provides the `--rootpw`, `--enable-ssh` and `--authorized-key` options.

- You must specify the vSphere target and its credentials, either in the `--target` option or separately in the `--user` and `--password` options. 
      
    The credentials that you provide must have the following privilege on the endpoint VM:<pre>Virtual machine.Guest Operations.Guest Operation Program Execution</pre>

- You must specify the ID or name of the VCH to debug.
- You might need to provide the thumbprint of the vCenter Server or ESXi host certificate. Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.
- You enable shell access by specifying a password for the root user on the VCH endpoint VM in the `--rootpw` option. Setting a password on the VCH allows you to access the VCH by using the VM console. If you also set the `--enable-ssh` option, you can use this password to connect to the VCH by using SSH. Wrap the password in single quotes (Linux or Mac OS) or double quotes (Windows) if it includes shell characters such as `$`, `!` or `%`. <pre>--rootpw '<i>new_p@ssword</i>'</pre>
- When you use the password to log in to a VCH, you see the message that the password will expire in 0 days. To obtain a longer expiration period, use the Linux `passwd` command in the endpoint VM to set a new password. If the password expires, the VCH does not revert to the default security configuration from before you ran `vic-machine debug`. If you attempt to log in using an interactive password via the terminal or SSH, you see a prompt to change the password. If you are using an SSH key, you cannot log in until you either change the password or run `vic-machine debug` again.


## Example ##

This example sets a password to allow shell access to the VCH.<pre>$ vic-machine-<i>operating_system</i> debug
     --target <i>vcenter_server_or_esxi_host_address</i>
     --user <i>vcenter_server_or_esxi_host_username</i>
     --password <i>vcenter_server_or_esxi_host_password</i>
     --id <i>vch_id</i>
     --thumbprint <i>certificate_thumbprint</i>
     --rootpw '<i>new_p@ssword</i>' </pre>

### Output

The output of the `vic-machine debug` command includes confirmation that SSH access is enabled:

<pre>### Configuring VCH for debug ####
[...]
SSH to appliance:
ssh root@<i>vch_address</i>
[...]
Completed successfully</pre>   

