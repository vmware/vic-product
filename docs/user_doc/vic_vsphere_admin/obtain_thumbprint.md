# Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host #

If your vSphere environment uses untrusted, self-signed certificates, you must specify the thumbprint of the vCenter Server or ESXi host certificate in the `--thumbprint` option of each `vic-machine` command. If your vSphere environment uses trusted certificates that are signed by a known Certificate Authority (CA), you do not need to specify the `--thumbprint` option.

If you do not specify the `--thumbprint` option, `vic-machine` commands fail with certificate verification errors that include the thumbprint of the target. Verify that the thumbprint in the error message is valid before attempting to run `vic-machine` again.

## Use SSL to Obtain Certificate Thumbprints

You can use SSL to obtain the vCenter Server or ESXi host certificate thumbprint before running `vic-machine` commands, or to confirm that a thumbprint in an error message is valid.

<pre>$ echo -n | openssl s_client -connect <i>vcenter_server_or_esxi_host_address</i>:443 2>/dev/null | openssl x509 -noout -fingerprint -sha1</pre>

This command is valid for vCenter Server instances that run on Windows, vCenter Server appliances, and ESXi hosts. 

## Obtain Certificate Thumbprints from Platform Services Controller

You can obtain a vCenter Server certificate thumbprint by logging into the Platform Services Controller for that vCenter Server instance and selecting **Certificate Management** > **Machine Certificates**, selecting a certificate, and clicking **Show Details**.