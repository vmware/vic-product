# Index of `vic-machine create` Options #

The table in this topic includes the full list of options for the `vic-machine create` command, with links to the sections of the documentation that describe them.

The options are presented in the same order as the output of `vic-machine create --extended-help`.

|**Option**|**Documentation**|  
|---|---|
|`--target`|[Basic `vic-machine create` Options](running_vicmachine_cmds.md#target)|
|`--user`|[Basic `vic-machine create` Options](running_vicmachine_cmds.md#user)|
|`--password`|[Basic `vic-machine create` Options](running_vicmachine_cmds.md#password)|
|`--thumbprint`|[Basic `vic-machine create` Options](running_vicmachine_cmds.md#thumbprint)|
|`--name`|[General Virtual Container Host Settings](vch_general_settings.md#name)|
|`--compute-resource`|[Virtual Container Host Compute Capacity](vch_compute.md#compute-resource)|
|`--affinity-vm-group`|[Add Virtual Container Hosts to a DRS Affinity Group](vch_affinity_group.md)|
|`--ops-user`|[Configure the Operations User](set_up_ops_user.md)|
|`--ops-password`|[Configure the Operations User](set_up_ops_user.md#credentials)|
|`--ops-grant-perms`|[Configure the Operations User](set_up_ops_user.md#perms)|
|`--image-store`|[Specify the Image Datastore](image_store.md)|
|`--base-image-size`|[Specify the Image Datastore](image_store.md#baseimagesize)|
|`--container-name-convention`|[General Virtual Container Host Settings](vch_general_settings.md#container-name-convention)|
|`--volume-store`|[Specify Volume Datastores](volume_stores.md)|
|`--dns-server`|[Configure the Public Network](public_network.md#dns-server)|
|`--bridge-network`|[Configure Bridge Networks](bridge_network.md)|
|`--bridge-network-range`|[Configure Bridge Networks](bridge_network.md#bridge-range)|
|`--client-network`|[Configure the Client Network](client_network.md)|
|`--client-network-gateway`|[Configure the Client Network](client_network.md#gateway)|
|`--client-network-ip`|[Configure the Client Network](client_network.md#static-ip)|
|`--public-network`|[Configure the Public Network](public_network.md)|
|`--public-network-gateway`|[Configure the Public Network](public_network.md#gateway)|
|`--public-network-ip`|[Configure the Public Network](public_network.md#static-ip)|
|`--management-network`|[Configure the Management Network](mgmt_network.md)|
|`--management-network-gateway`|[Configure the Management Network](mgmt_network.md#gateway)|
|`--management-network-ip`|[Configure the Management Network](mgmt_network.md#static-ip)|
|`--container-network`|[Configure Container Networks](container_networks.md)|
|`--container-network-gateway`|[Configure Container Networks](container_networks.md#gateway)|
|`--container-network-ip-range`|[Configure Container Networks](container_networks.md#ip-range)|
|`--container-network-dns`|[Configure Container Networks](container_networks.md#dns)|
|`--container-network-firewall`|[Configure Container Networks](container_networks.md#container-network-firewall)|
|`--memory`|[Virtual Container Host Compute Capacity](vch_compute.md#memory)|
|`--memory-reservation`|[Virtual Container Host Compute Capacity](vch_compute.md#memoryres)|
|`--memory-shares`|[Virtual Container Host Compute Capacity](vch_compute.md#memoryshares)|
|`--endpoint-memory`|[Virtual Container Host Compute Capacity](vch_compute.md#endpointmemory)|
|`--cpu`|[Virtual Container Host Compute Capacity](vch_compute.md#cpu)|
|`--cpu-reservation`|[Virtual Container Host Compute Capacity](vch_compute.md#cpures)|
|`--cpu-shares`|[Virtual Container Host Compute Capacity](vch_compute.md#cpushares)|
|`--endpoint-cpu`|[Virtual Container Host Compute Capacity](vch_compute.md#endpointcpu)|
|`--tls-server-key`|[Virtual Container Host Certificate Options](vch_cert_options.md#server-key)|
|`--tls-server-cert`|[Virtual Container Host Certificate Options](vch_cert_options.md#server-cert)|
|`--tls-cname`|[Virtual Container Host Certificate Options](vch_cert_options.md#tls-cname)|
|`--tls-cert-path`|[Virtual Container Host Certificate Options](vch_cert_options.md#cert-path)|
|`--no-tlsverify`|[Disable Client Verification](tls_unrestricted.md#no-tlsverify)|
|`--organization`|[Virtual Container Host Certificate Options](vch_cert_options.md#org)|
|`--certificate-key-size`|[Virtual Container Host Certificate Options](vch_cert_options.md#keysize)|
|`--tls-ca`|[Virtual Container Host Certificate Options](vch_cert_options.md#ca-pem)|
|`--no-tls`|[Disable Client Verification](tls_unrestricted.md#no-tls)|
|`--registry-ca`|[Configure Registry Access](vch_registry.md#registry-ca)|
|`--insecure-registry`|[Configure Registry Access](vch_registry.md#insecure-registry)|
|`--whitelist-registry`|[Configure Registry Access](vch_registry.md#whitelist-registry)|
|`--https-proxy`|[Configure VCHs to Use Proxy Servers](vch_proxy.md#https)|
|`--http-proxy`|[Configure VCHs to Use Proxy Servers](vch_proxy.md#http)|
|`--syslog-address`|[General Virtual Container Host Settings](vch_general_settings.md#syslog)|
|`--appliance-iso`|[Virtual Container Host Boot Options](vch_boot_options.md#appliance-iso)|
|`--bootstrap-iso`|[Virtual Container Host Boot Options](vch_boot_options.md#bootstrap-iso)|
|`--force`|[Basic `vic-machine create` Options](running_vicmachine_cmds.md#force)|
|`--timeout`|[Basic `vic-machine create` Options](running_vicmachine_cmds.md#timeout)|
|`--asymmetric-routes`|[Configure the Management Network](mgmt_network.md#asymmetric-routes)|
|`--debug`|[General Virtual Container Host Settings](vch_general_settings.md#debug)|