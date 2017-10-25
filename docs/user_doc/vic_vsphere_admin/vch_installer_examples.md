# Advanced Examples of Deploying a VCH #

This topic provides examples of the options of the `vic-machine create` command to use when deploying virtual container hosts (VCHs) in various vSphere configurations.

- [General Deployment Examples](#general)
  - [Deploy to a vCenter Server Cluster with Multiple Datacenters and Datastores](#cluster)
  - [Deploy to a Specific Standalone Host in vCenter Server](#standalone)
  - [Deploy to a Resource Pool on an ESXi Host](#rp_host)
  - [Deploy to a Resource Pool in a vCenter Server Cluster](#rp_cluster)
  - [Set Limits on Resource Use](#customized)
- [Specify One or More Volume Stores](#volume-stores)
- [Registry Server Examples](#regserv)
  - [Authorize Access to an Insecure Private Registry Server](#registry)
  - [Authorize Access to Secure Registries and vSphere Integrated Containers Registry](#secureregistry)
  - [Authorize Access to a Whitelist of Registries](#whitelist)

For simplicity, all examples that do not relate explicitly to certificate use specify the `--no-tls` option.

For detailed descriptions of all of the `vic-machine create` options, see [VCH Deployment Options](vch_installer_options.md). For information about how to obtain the certificate thumbprint before running `vic-machine`, see [Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host](obtain_thumbprint.md). 

**NOTE**: Wrap any option arguments that include spaces or special characters in quotes. Use single quotes if you are using `vic-machine` on a Linux or Mac OS system and double quotes on a Windows system.

Option arguments that might require quotation marks include the following:

- User names and passwords in `--target`, `--user`, `--password`, `--ops-user`, and `--ops-password`.
- Datacenter names in `--target`.
- VCH names in `--name`.
- Datastore names and paths in `--image-store` and `--volume-store`.
- Network and port group names in all networking options.
- Cluster and resource pool names in `--compute-resource`.
- Folder names in the paths for `--tls-cert-path`, `--tls-server-cert`, `--tls-server-key`, `--appliance-iso`, and `--bootstrap-iso`.


## General Deployment Examples <a id="general"></a>

The examples in this section demonstrate the deployment of VCHs in different vSphere environments.


### Deploy to a vCenter Server Cluster with Multiple Datacenters and Datastores <a id="cluster"></a>

If vCenter Server has more than one datacenter, you specify the datacenter in the `--target` option.

If vCenter Server manages more than one cluster, you use the `--compute-resource` option to specify the cluster on which to deploy the VCH.

When deploying a VCH to vCenter Server, you must use the `--bridge-network` option to specify an existing port group for container VMs to use to communicate with each other. For information about how to create a distributed virtual switch and port group, see the section on vCenter Server Network Requirements in [Environment Prerequisites for VCH Deployment](vic_installation_prereqs.md#networkreqs).

This example deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user and password in the `--target` option. The user name is wrapped in quotes, because it contains the `@` character.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses a port group named `vic-bridge` for the bridge network. 
- Designates `datastore1` as the datastore in which to store container images, the files for the VCH appliance, and container VMs. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>


### Deploy to a Specific Standalone Host in vCenter Server <a id="standalone"></a> 

If vCenter Server manages multiple standalone ESXi hosts that are not part of a cluster, you use the `--compute-resource` option to specify the address of the ESXi host to which to deploy the VCH.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, bridge network, and name for the VCH.
- Deploys the VCH on the ESXi host with the FQDN `esxihost1.organization.company.com` in the datacenter `dc1`. You can also specify an IP address.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--image-store datastore1
--bridge-network vch1-bridge
--compute-resource esxihost1.organization.company.com
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>


### Deploy to a Resource Pool on an ESXi Host <a id="rp_host"></a>

To deploy a VCH in a specific resource pool on an ESXi host that is not managed by vCenter Server, you specify the resource pool name in the `--compute-resource` option. 

This example deploys a VCH with the following configuration:

- Specifies the user name and password, image store, and a name for the VCH.
- Designates `rp 1` as the resource pool in which to place the VCH. The resource pool name is wrapped in quotes, because it contains a space.

<pre>vic-machine-<i>operating_system</i> create
--target root:<i>password</i>@<i>esxi_host_address</i>
--compute-resource 'rp 1'
--image-store datastore1
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>


### Deploy to a Resource Pool in a vCenter Server Cluster <a id="rp_cluster"></a>

To deploy a VCH in a resource pool in a vCenter Server cluster, you specify the resource pool in the `compute-resource` option.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, datacenter, image store, bridge network, and name for the VCH.
- Designates `rp 1` as the resource pool in which to place the VCH. In this example, the resource pool name `rp 1` is unique across all hosts and clusters, so you only need to specify the resource pool name.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource 'rp 1'
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

If the name of the resource pool is not unique across all clusters, for example if two clusters each contain a resource pool named `rp 1`, you must specify the full path to the resource pool in the `compute-resource` option, in the format <i>cluster_name</i>/Resources/<i>resource_pool_name</i>.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource 'cluster 1'/Resources/'rp 1'
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

### Set Limits on Resource Use <a id="customized"></a>

To limit the amount of system resources that the container VMs in a VCH can use, you can set resource limits on the VCH vApp. 

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Sets resource limits on the VCH by imposing memory and CPU reservations, limits, and shares.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--memory 1024
--memory-reservation 1024
--memory-shares low
--cpu 1024
--cpu-reservation 1024
--cpu-shares low
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

For more information about setting resource use limitations on VCHs, see the [Advanced Deployment Options](vch_installer_options.md#deployment) and [Advanced Resource Management Options](vch_installer_options.md#adv-mgmt) sections in VCH Deployment Options.

## Specify Volume Stores <a id="volume-stores"></a>

If container application developers will use the `docker volume create` command to create containers that use volumes, you must create volume stores when you deploy VCHs. You specify volume stores in the `--volume-store` option. You can specify `--volume-store` multiple times to create multiple volume stores. 

When you create a volume store, you specify the name of the datastore to use and an optional path to a folder on that datastore. You also specify a descriptive name for that volume store for use by Docker.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, datacenter, cluster, bridge network, and name for the VCH.
- Specifies the `volumes` folder on `datastore 1` as the default volume store. Creating a volume store named `default` allows container application developers to create anonymous or named volumes by using `docker create -v`. 
- Specifies a second volume store named `volume_store_2` in the `volumes` folder on `datastore 2`. 
- Specifies a volume store named `shared_volume` in a NFS share point, from which containers can mount shared volumes.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--bridge-network vch1-bridge
--image-store 'datastore 1'
--volume-store 'datastore 1'/volumes:default
--volume-store 'datastore 2'/volumes:volume_store_2
--volume-store nfs://nfs_store/path/to/share/point:shared_volume
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

For more information about volume stores, see the [volume-store section](vch_installer_options.md#volume-store) in VCH Deployment Options. 


## Security Examples <a id="security"></a>

The examples in this section demonstrate how to configure a VCH to use Certificate Authority (CA) certificates to enable `TLSVERIFY` in your Docker environment, and to allow access to insecure registries of Docker images.







## Registry Server Examples <a id="regserv"></a>

The examples in this section demonstrate how to configure a VCH to use a private registry server, for example vSphere Integrated Containers Registry.

### Authorize Access to an Insecure Private Registry Server <a id="registry"></a>

To authorize connections from a VCH to a private registry server without verifying the certificate of that registry, set the `--insecure-registry` option. If you authorize a VCH to connect to an insecure private registry server, the VCH attempts to access the registry server via HTTP if access via HTTPS fails. VCHs always use HTTPS when connecting to registry servers for which you have not authorized insecure access. You can specify `insecure-registry` multiple times to allow connections from the VCH to multiple insecure private registry servers.

**NOTE**: You cannot configure VCHs to connect to vSphere Integrated Containers Registry instances as insecure registries. Connections to vSphere Integrated Containers Registry always require HTTPS and a certificate.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Authorizes the VCH to pull Docker images from the insecure private registry servers located at the URLs <i>registry_URL_1</i> and <i>registry_URL_2</i>.
- The registry server at <i>registry_URL_2</i> listens for connections on port 5000. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--insecure-registry <i>registry_URL_1</i>
--insecure-registry <i>registry_URL_2:5000</i>
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

For more information about configuring VCHs to allow connections to insecure private registry servers, see the section on the [`--insecure-registry` option](vch_installer_options.md#insecure-registry) in VCH Deployment Options.

### Authorize Access to Secure Registries and vSphere Integrated Containers Registry <a id="secureregistry"></a>

For an example of how to use `--registry-ca` to authorize access to vSphere Integrated Containers Registry or to another secure registry, see [Deploy a VCH for Use with vSphere Integrated Containers Registry](deploy_vch_registry.md).

### Authorize Access to a Whitelist of Registries <a id="whitelist"></a>

To restrict the registries to which a VCH allows access, set the `--whitelist-registry` option. You can specify `--whitelist-registry` multiple times to add multiple registries to the whitelist. You use `--whitelist-registry` in combination with the `--registry-ca`  and `--insecure-registry` options.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Adds to the whitelist:
      - The single registry instance running at 10.2.40.40:443
      - All registries running in the range 10.2.2.1/24 
      - All registries in the domain *.mycompany.com
- Provides the CA certificate for the registry instance 10.2.40.40:443.
- Adds a single instance of an insecure registry to the whitelist by specifying `--insecure-registry`.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--whitelist-registry="10.2.40.40:443" 
--whitelist-registry=10.2.2.1/24 
--whitelist-registry=*.mycompany.com 
--registry-ca=/home/admin/mycerts/ca.crt
--insecure-registry=192.168.100.207  
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

For more information about configuring VCHs to allow connections to a whitelist of registries, see the section on the [`--whitelist-registry` option](vch_installer_options.md#whitelist-registry) in VCH Deployment Options.
