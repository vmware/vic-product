# Set Environment Variables for Key `vic-machine` Options #

If you deploy multiple virtual container hosts (VCHs) to the same vCenter Server instance or ESXi host, you can simplify `vic-machine` commands by setting environment variables for certain key `vic-machine` options.

You can set environment variables for the following `vic-machine` options. 

|**Option**|**Variable**|**Description**|
|---|---|---|
|`--target`|`VIC_MACHINE_TARGET`|The address of the vCenter Server instance or ESXi host on which you are deploying VCHs.|
|`--user`|`VIC_MACHINE_USER`|The user name for the vSphere account that you use when running `vic-machine` commands. Use an account with administrator privileges.|
|`--password`|`VIC_MACHINE_PASSWORD`|The password for the vSphere user account.|
|`--thumbprint`|`VIC_MACHINE_THUMBPRINT`|The thumbprint of the vCenter Server or ESXi host certificate.|

**NOTE**: You cannot include the vSphere user name and password in the `VIC_MACHINE_TARGET` environment variable. You must either specify the user name and password in the `VIC_MACHINE_USER` and `VIC_MACHINE_PASSWORD` environment variables, or use the `--user` and `--password` options when you run `vic-machine`.

When you run any of the different `vic-machine` commands, `vic-machine` checks whether environment variables are present in the system. If you have set any or all of the environment variables, `vic-machine` automatically uses the values from those environment variables. You only need to specify the additional `vic-machine` options.

The following examples show some simplified `vic-machine` commands that you can run if you set all four environment variables.

- List VCHs:<pre>vic-machine-<i>operating_system</i> ls</pre>
- Inspect a VCH: <pre>vic-machine-<i>operating_system</i> inspect --id vm-123</pre>
- Create a basic VCH:<pre>vic-machine-<i>operating_system</i> create --bridge-network vic-bridge --no-tls --name vch-no-tls</pre> 
- Upgrade a VCH: <pre>vic-machine-<i>operating_system</i> upgrade --id vm-123</pre>
- Configure a VCH, for example to add a new volume store: <pre>vic-machine-<i>operating_system</i> configure --id vm-123 --volume-store <i>datastore_name</i>/<i>datastore_path</i>:default</pre>
- Delete a VCH: <pre>vic-machine-<i>operating_system</i> delete --id vm-123</pre>
