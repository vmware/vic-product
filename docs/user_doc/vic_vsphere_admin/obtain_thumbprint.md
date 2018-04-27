# Obtain vSphere Certificate Thumbprints #

If your vSphere environment uses untrusted, self-signed certificates to authenticate connections, you must specify the thumbprint of the vCenter Server or ESXi host certificate in all `vic-machine` commands to deploy and manage virtual container hosts (VCHs). If your vSphere environment uses trusted certificates that are signed by a known Certificate Authority (CA), you do not need to specify the `--thumbprint` option. You can set the thumbprint as an environment variable. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Common `vic-machine` Options](vic_env_variables.md).

If you deploy VCHs from the vSphere Client, the Create Virtual Container Host wizard obtains the thumbprint automatically. However, you might still need to obtain the thumbprint for use in other `vic-machine` commands, for example `vic-machine update firewall` or `vic-machine configure`.

You can use either SSH and OpenSSL or the Platform Services Controller to obtain certificate thumbprints, either before you run `vic-machine` commands, or to confirm that a thumbprint in an error message is valid.

- [vCenter Server Appliance or ESXi Host](#cert_vc_esx) 
- [Platform Services Controller](#cert_psc)

## vCenter Server Appliance or ESXi Host <a id="cert_vc_esx"></a>

You can use SSH and OpenSSL to obtain the certificate thumbprint for a vCenter Server Appliance instance or an ESXi host. 

1. Use SSH to connect to the vCenter Server Appliance or ESXi host as `root` user.<pre>$ ssh root@<i>vcsa_or_esxi_host_address</i></pre>
2. Use `openssl` to view the certificate fingerprint.

   - vCenter Server Appliance: <pre>openssl x509 -in /etc/vmware-vpx/ssl/rui.crt -fingerprint -sha1 -noout</pre>
   - ESXi host: <pre>openssl x509 -in /etc/vmware/ssl/rui.crt -fingerprint -sha1 -noout</pre>
3. Copy the certificate thumbprint for use in the `--thumbprint` option of `vic-machine` commands or to set it as an environment variable.

## Platform Services Controller <a id="cert_psc"></a>

You can obtain a vCenter Server certificate thumbprint by logging into the Platform Services Controller for that vCenter Server instance.

1. Log in to the Platform Services Controller interface. 

    - Embedded Platform Services Controller: https://<i>vcenter_server_address</i>/psc
    - Standalone Platform Services Controller: https://<i>psc_address</i>/psc

2. Select **Certificate Management** and enter a vCenter Single Sign-On password.
3. Select **Machine Certificates**, select a certificate, and click **Show Details**.
3. Copy the thumbprint for use in the `--thumbprint` option of `vic-machine` commands or to set it as an environment variable.