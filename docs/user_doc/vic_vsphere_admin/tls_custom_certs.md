# Use Custom Server Certificates



### Use Custom Server Certificates <a id="usecustom"></a>

You use the `--tls-server-cert` and `--tls-server-key` options to provide the paths to a custom X.509 server certificate and its key when you deploy a VCH. The paths to the certificate and key files must be relative to the location from which you are running `vic-machine create`.

This example `vic-machine create` command deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.







### Combine Custom Server Certificates and Auto-Generated Client Certificates <a id="certcombo"></a>

You can create a VCH with a custom server certificate by specifying the paths to custom `server-cert.pem` and `server-key.pem` files in the `--tls-server-cert` and `--tls-server-key` options. The key should be un-encrypted. Specifying the `--tls-server-cert` and `--tls-server-key` options for the server certificate does not affect the automatic generation of client certificates. If you specify the [`--tls-cname`](vch_cert_options.md#tls-cname) option to match the common name value of the server certificate, `vic-machine create` generates self-signed certificates for Docker client authentication and deployment of the VCH succeeds.

This example `vic-machine create` command deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Provides the paths relative to the current location of the `*.pem` files for the custom server certificate and key files.
- Specifies the common name from the server certificate in the `--tls-cname` option. The `--tls-cname` option is used in this case to ensure that the auto-generated client certificate is valid for the resulting VCH, given the network configuration.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--tls-server-cert ../some/relative/path/<i>certificate_file</i>.pem
--tls-server-key ../some/relative/path/<i>key_file</i>.pem
--tls-cname <i>cname_from_server_cert</i>
--name vch1
--thumbprint <i>certificate_thumbprint</i>
</pre>