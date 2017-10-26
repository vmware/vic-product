# Unrestricted Access to the Docker API <a id="unrestricted"></a>

To deploy a VCH that does not restrict access to the Docker API, use the `--no-tlsverify` option. To completely disable TLS authentication, use the `--no-tls` option.

- [`vic-machine `Options](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Options <a id="options"></a>

### `--no-tlsverify` <a id="no-tlsverify"></a>

Short name: `--kv`

The `--no-tlsverify` option prevents the use of CAs for client authentication. You still require a server certificate if you use `--no-tlsverify`. You can still supply a custom server certificate by using the  [`--tls-server-cert`](#cert) and [`--tls-server-key`](#key)  options. If you do not use `--tls-server-cert` and `--tls-server-key` to supply a custom server certificate, `vic-machine create` generates a self-signed server certificate. If you specify `--no-tlsverify` there is no access control, however connections remain encrypted.

When you specify the `--no-tlsverify` option, `vic-machine create` performs the following actions during the deployment of the VCH.

- Generates a self-signed server certificate if you do not specify `--tls-server-cert` and `--tls-server-key`.
- Creates a folder with the same name as the VCH in the location in which you run `vic-machine create`.
- Creates an environment file named <code><i>vch_name</i>.env</code> in that folder, that contains the `DOCKER_HOST=vch_address` environment variable, that you can provide to container developers to use to set up their Docker client environment.

If you deploy a VCH with the `--no-tlsverify` option, container developers run Docker commands with the `--tls` option, and the `DOCKER_TLS_VERIFY` environment variable must not be set. Note that setting `DOCKER_TLS_VERIFY` to 0 or `false` has no effect. 

The `--no-tlsverify` option takes no arguments. 

<pre>--no-tlsverify</pre>

### `--no-tls` <a id="no-tls"></a>

Short name: `-k`

Disables TLS authentication of connections between the Docker client and the VCH. VCHs use neither client nor server certificates.

Set the `no-tls` option if you do not require TLS authentication between the VCH and the Docker client. Any Docker client can connect to the VCH if you disable TLS authentication and connections are not encrypted. 

If you use the `no-tls` option, container developers connect Docker clients to the VCH via port 2375, instead of via port 2376.

<pre>--no-tls</pre>

## Example `vic-machine` Commands <a id="example"></a>