# Using the developer preview of the VCH Management API

vSphere Integrated Containers 1.3 and 1.4 include a developer preview of an API
for management of Virtual Container Hosts (VCHs). This is not a stable API;
future releases will not be backwards-compatible with this version of the API.

This means two things:
1. You shouldn't build production applications using this API.
2. It's the perfect time to give the API a try and provide feedback!

## Expectations

This tutorial will assume you have installed and are familiar with the following
command-line tools:
 - [`curl`](https://curl.haxx.se/), which will be used to issue API requests.
 - [`jq`](https://stedolan.github.io/jq/manual/), which will be used to filter
   and format API responses.

This tutorial will also assume that you have a VMware vSphere environment which
is managed by VMware vCenter Server.

## Getting started

To use the examples from this tutorial, you'll need to download and install
vSphere Integrated Containers 1.3.0 or later.

1. [Download](http://www.vmware.com/go/download-vic) an OVA.
2. [Deploy the appliance](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_vsphere_admin/deploy_vic_appliance.html).
3. Optionally, [install the vSphere Client plug-in](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_vsphere_admin/install_vic_plugin.html)
4. [Open the required ports on ESXi Hosts](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_vsphere_admin/open_ports_on_hosts.html)

Examples that follow will use "vic.example.com" to represent the network address
of the deployed appliance. Replace this value with the hostname or IP address of
your VIC Appliance as necessary.

## Background

In vSphere Integrated Containers, [Virtual Container Hosts (VCHs)](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_overview/intro_to_vic_engine.html#virtual-container-hosts-)
serve as the functional equivalent of a Linux VM that runs Docker. VCHs can be
deployed using the [`vic-machine` CLI](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_vsphere_admin/deploy_vch.html)
or via the [vSphere Client Plugin](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_vsphere_admin/deploy_vch_client.html).

The VCH Management API serves as an alternative to the `vic-machine` CLI, and is
intended to support automation and application development use cases. An OpenAPI
definition is provided which describes our vision for the API, and a subset of
its functionality has been implemented for version 1.3.0 and later.

This API makes use of standard HTTP verbs and headers and represents most data
using [JSON](https://tools.ietf.org/html/rfc7159).

## Tutorial

### Verifying the API is accessible

To verify that the API is accessible, we begin by issuing a request to the
version endpoint. It's safe to just ignore the value that's returned.

```
curl "https://vic.example.com:8443/container/version"
```

If your VIC Appliance is using the default self-signed certificates, you will
receive an error from `curl`. In subsequent commands, you will be transmitting
your vSphere credentials to the API, so it is important that you establish a
secure connection to the appliance.

While `curl` does not directly support [Trust On First Use](https://en.wikipedia.org/wiki/Trust_on_first_use),
such behavior can be imitated by connecting to the above address in a browser,
downloading the presented certificate, and referring to it in subsequent
commands using using the `--cacert` option.

For lab environments where the secrecy of your password is not important, you
can invoke `curl` with the `--insecure` option to disable certificate validation.

The remaining examples will assume you deployed the OVA using custom
certificates trusted by your system. (If not, just use either `--cacert` or
`--insecure` as discussed above in each subsequent example.)

### Listing VCHs

Next, we will list the VCHs within a system. Unless you (or another user of this
vSphere system) have created a VCH (e.g., by using the `vic-machine` CLI), this
list will be empty.

To invoke this command, we need to supply a few pieces of information:
- The address of your vCenter Server, stored in the `VC_IP` environment variable
  (e.g., `192.0.2.1`).
- Your vCenter Server username, stored in the `VC_USERNAME` envrionment variable
  (e.g., `administrator@vsphere.local`).
- Your vCenter Server password, entered interactively.

```bash
curl --silent --user "$VC_USERNAME" --request GET "http://vic.example.com:8443/container/target/$VC_IP/vch" --header "Accept: application/json" | jq
```

If you receive an error about certificate validation, your vCenter Server may
not be using a certificate signed by a certificate authority trusted by your
system: 

```json
{
  "message": "Validation Error: x509: cannot validate certificate for 192.0.2.1 because it doesn't contain any IP SANs"
}
```

To bypass this, you can store the [expected thumbprint](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_vsphere_admin/obtain_thumbprint.html)
 for the certificate in the `THUMBPRINT` environment variable (e.g.,
`12:34:56:78:9A:BC:DE:F0:12:34:56:78:9A:BC:DE:F0:11:22:33:44`) and provide it as
a query parameter to this API call, or any which follow:

```bash
curl --silent --user "$VC_USERNAME" --request GET "http://vic.example.com:8443/container/target/$VC_IP/vch?thumbprint=$THUMBPRINT" --header "Accept: application/json" | jq
```

The remaining examples will assume your vCenter Server is using a certificate
signed by a certificate authority trusted by your system. (If not, just use
`thumbprint` query parameter discussed above in each subsequent example.)

If you have no VCHs on this system, the output will appear as follows:

```json
{
  "vchs": []
}
```

You may scope the list (and all subsequent API calls discussed in this tutorial)
to a datacenter (`DATACENTER_MOID`, e.g., `datacenter-1`) within the vCenter:

```bash
curl --silent --user "$VC_USERNAME" --request GET "http://vic.example.com:8443/container/target/$VC_IP/datacenter/$DATACENTER_MOID/vch" --header "Accept: application/json" | jq
```

### Creating a VCH

To create a VCH, we represent its configuration in JSON. Objects such as the
compute resource and network port groups may be referred to by name or id. 

This example represents a VCH named "Test VCH" in a cluster named "MyCluster",
using "MyPublicNetwork" as its public network, "MyBridgeNetwork" as its bridge
network, and "MyDatastore" for its image store. You'll need to customize the
values to match your environment. Guidance about these objects can be found in
the [VCH documentation](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_vsphere_admin/vch_deployment_options.html)

```json
{
    "name": "Test VCH",
    "compute": {
        "resource": {
            "name": "MyCluster"
        }
    },
    "network": {
        "bridge": {
            "ip_range": "172.16.0.0/12",
            "port_group": {
                "name": "MyBridgeNetwork"
            }
        },
        "public": {
            "port_group": {
                "name": "MyPublicNetwork"
            }
        }
    },
    "storage": {
        "image_stores": ["ds://MyDatastore"]
    },
    "auth": {
        "server": {
            "generate": {
                "cname": "vch.example.com",
                "organization": "MyOrganization",
                "size": {
                    "value": 2048,
                    "units": "bits"
                }
            }
        },
        "client": {
            "no_tls_verify": true
        }
    }
}
```

Note that a `client` element with a `"no_tls_verify": true` will allow
unrestricted access to this VCH! Instead, you could supply a `client` element
with a list of `certificate_authorities`:

```json
        "client": {
            "certificate_authorities": [
                {
                    "pem": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----\n"
                },
                {
                    "pem": "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----\n"
                }
            ]
        }
```

To create the VCH, we can place the above data object in a file (e.g.,
`data.json`) and issue a `POST` request:

```bash
curl --silent --user "$VC_USERNAME" --request POST "http://vic.example.com:8443/container/target/$VC_IP/vch" --data "@data.json" --header "Accept: application/json" --header "Content-Type: application/json" | jq
```

We expect a `201 Created` resonse with a body that may contain a reference to a
vSphere task related to the VCH creation operation.

We may receive a `400 Bad Request` if there is something wrong with our request
(e.g., we refer to an object which cannot be found) or a `500 Internal Server
Error` if the request is valid, but the creation fails. The body of such a
response should contain an error message object with more information.

For more information on the structure of this data object, refer to the relevant
portion of the OpenAPI definition, retrievable from the API itself:

```bash
curl --silent "http://vic.example.com:8443/swagger.json" --header "Accept: application/json" | jq ".definitions.VCH"
```

### Using a VCH

After the VCH has been created, it should be included in the [list](#listing-vchs)
of VCHs:

```json
{
  "vchs": [
    {
      "admin_portal": "https://198.51.100.1:2378",
      "docker_host": "198.51.100.1:2376",
      "id": "vm-100",
      "name": "Test VCH",
      "upgrade_status": "Up to date",
      "version": "..."
    }
  ]
}
```

- The `admin_portal` property provides the address of the [VCH Admin Portal](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_vsphere_admin/access_vicadmin.html).
- The `docker_host` property provides the value which would be passed to the
  `--host` (`-H`) option of the `docker` CLI when [connecting to the VCH](https://vmware.github.io/vic-product/assets/files/html/1.4/vic_app_dev/configure_docker_client.html).

#### Authenticating clients

If you created the VCH with a `client` element containing a list of
`certificate_authorities`, pass a private key and corresponding certificate
signed by one of those certificate authorities to the `docker` client using
the `--tls`, `--tlscert`, and `--tlskey` options.

#### Authenticating the server

To download the VCH's server certificate, issue a request to the VCH's
`certificate` sub-resource:

```bash
curl --silent --user "$VC_USERNAME" --request GET "http://vic.example.com:8443/container/target/$VC_IP/vch/vm-100/certificate" --output "server-cert.pem" --header "Accept: application/x-pem-file"
```

This can be used in conjunction with the `--tlsverify` and `--tlscacert` options
to instruct your `docker` client to verify it is communicating with the VCH.

### Inspecting a VCH

Using the `id` returned from [list](#listing-vchs), we can inspect the VCH:

```bash
curl --silent --user "$VC_USERNAME" --request GET "http://vic.example.com:8443/container/target/$VC_IP/vch/vm-100" --header "Accept: application/json" | jq
```

Note that the response may not match the creation request exactly. Object names
provided during creation (e.g., for portgroups) may be represented by ids in the
response. Additionally, responses will include a `runtime` element which can not
be supplied as a part of a creation request.

#### Accessing a creation log

To access the log information for the VCH creation operation, issue a request to
the VCH's `log` sub-resource:

```bash
curl --silent --user "$VC_USERNAME" --request GET "http://vic.example.com:8443/container/target/$VC_IP/vch/vm-100/log" --output "vic-machine.log" --header "Accept: text/plain"
```

The information in this file is very similar to what would be found in the
`vic-machine.log` produced by the `vic-machine` CLI.

## Getting help and providing feedback

Please let us know if you have questions, comments, or requests about the API.

Understanding your use cases for the API early in the development process will
better enable us to consider those use cases as we continue implementation.

- Submit an [issue in Github](https://github.com/vmware/vic/issues/new?labels=area/apis,component/vic-machine,kind/customer-found,team/lifecycle&title=VCH%20Management%20API%20Feedback:%20)
- Send us a message on https://vmwarecode.slack.com/messages/vic-engine. You can
  access the vSphere Integrated Containers Slack channels by signing up at
  https://code.vmware.com/web/code/join.

