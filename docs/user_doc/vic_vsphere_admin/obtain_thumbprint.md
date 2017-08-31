# Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host #

If your vSphere environment uses untrusted, self-signed certificates, you must specify the thumbprint of the vCenter Server or ESXi host certificate in the `--thumbprint` option of each `vic-machine` command. If your vSphere environment uses trusted certificates that are signed by a known Certificate Authority (CA), you do not need to specify the `--thumbprint` option.

If you do not specify the `--thumbprint` option, `vic-machine` commands fail with certificate verification errors that include the thumbprint of the target. In this case, you should verify that the thumbprint in the error message is valid before attempting to run `vic-machine` again.

You can use either SSH and OpenSSL or the Platform Services Controller to obtain certificate thumbprints, either before you run `vic-machine` commands, or to confirm that a thumbprint in an error message is valid.

After you obtain the certificate thumbprint from vCenter Server or an ESXi host, you can set it as a `vic-machine` environment variable so that you do not have to specify `--thumbprint` in every command. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Key vic-machine Options](vic_env_variables.md).

## Obtain Certificate Thumbprints from an ESXi Host 

You can use SSH and OpenSSL to obtain the certificate thumbprint for a vCenter Server Appiance instance or an ESXi host. 

1. Use SSH to connect to the vCenter Server Appliance or ESXi host as `root` user.<pre>$ ssh root@<i>vcsa_or_esxi_host_address</i></pre>
2. Use `openssl` to view the certificate fingerprint.

   - vCenter Server Appliance: <pre>openssl x509 -in /etc/vmware-vpx/ssl/rui.crt -fingerprint -sha1 -noout</pre>
   - ESXi host: <pre>openssl x509 -in /etc/vmware/ssl/rui.crt -fingerprint -sha1 -noout</pre>
3. Copy the certificate thumbprint for use in the `--thumbprint` option of `vic-machine` commands.

## Obtain Certificate Thumbprints from Platform Services Controller

You can obtain a vCenter Server certificate thumbprint by logging into the Platform Services Controller for that vCenter Server instance.

1. Log in to the Platform Services Controller interface. 

    - Embedded Platform Services Controller: https://<i>vcenter_server_address</i>/psc
    - Standalone Platform Services Controller: https://<i>psc_address</i>/psc

2. Select **Certificate Management** and enter a vCenter Single Sign-On password.
3. Select **Machine Certificates**, select a certificate, and click **Show Details**.
3. Copy the thumbprint for use in the `--thumbprint` option of `vic-machine` commands.