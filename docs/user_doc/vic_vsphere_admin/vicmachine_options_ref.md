# `vic-machine` Options Reference #

This topic includes lists of all of the options of the different `vic-machine` commands, with links to the sections of the documentation that describe them.

## `vic-machine create` Options <a id="create"></a>

|**Option**|**Documentation**|  
|---|---|
|`--affinity-vm-group`|[Virtual Container Host Compute Capacity](vch_compute.md)|
|`--appliance-iso`|[Virtual Container Host Boot Options](vch_boot_options.md#appliance-iso)|
|`--asymmetric-routes`|[Configure the Management Network](mgmt_network.md#asymmetric-routes)|
|`--base-image-size`|[Specify the Image Datastore](image_store.md#baseimagesize)|
|`--bootstrap-iso`|[Virtual Container Host Boot Options](vch_boot_options.md#bootstrap-iso)|
|`--bridge-network`|[Configure Bridge Networks](bridge_network.md)|
|`--bridge-network-range`|[Configure Bridge Networks](bridge_network.md#bridge-range)|
|`--bridge-network-width`|[Configure Bridge Networks](bridge_network.md#bridge-width)|
|`--certificate-key-size`|[Virtual Container Host Certificate Options](vch_cert_options.md#keysize)|
|`--client-network`|[Configure the Client Network](client_network.md)|
|`--client-network-gateway`|[Configure the Client Network](client_network.md#gateway)|
|`--client-network-ip`|[Configure the Client Network](client_network.md#static-ip)|
|`--compute-resource`|[Virtual Container Host Compute Capacity](vch_compute.md#compute-resource)|
|`--container-name-convention`|[General Virtual Container Host Settings](vch_general_settings.md#container-name-convention)|
|`--container-network`|[Configure Container Networks](container_networks.md)|
|`--container-network-dns`|[Configure Container Networks](container_networks.md#dns)|
|`--container-network-firewall`|[Configure Container Networks](container_networks.md#container-network-firewall)|
|`--container-network-gateway`|[Configure Container Networks](container_networks.md#gateway)|
|`--container-network-ip-range`|[Configure Container Networks](container_networks.md#ip-range)|
|`--containers`|[General Virtual Container Host Settings](vch_general_settings.md#container-limit)|
|`--cpu`|[Virtual Container Host Compute Capacity](vch_compute.md#cpu)|
|`--cpu-reservation`|[Virtual Container Host Compute Capacity](vch_compute.md#cpures)|
|`--cpu-shares`|[Virtual Container Host Compute Capacity](vch_compute.md#cpushares)|
|`--debug`|[General Virtual Container Host Settings](vch_general_settings.md#debug)|
|`--dns-server`|[Configure the Public Network](public_network.md#dns-server)|
|`--endpoint-cpu`|[Virtual Container Host Compute Capacity](vch_compute.md#endpointcpu)|
|`--endpoint-memory`|[Virtual Container Host Compute Capacity](vch_compute.md#endpointmemory)|
|`--force`|[Basic `vic-machine create` Options](using_vicmachine.md#force)|
|`--image-store`|[Specify the Image Datastore](image_store.md)|
|`--insecure-registry`|[Configure Registry Access](vch_registry.md#insecure-registry)|
|`--http-proxy`|[Configure VCHs to Use Proxy Servers](vch_proxy.md#http)|
|`--https-proxy`|[Configure VCHs to Use Proxy Servers](vch_proxy.md#https)|
|`--management-network`|[Configure the Management Network](mgmt_network.md)|
|`--management-network-gateway`|[Configure the Management Network](mgmt_network.md#gateway)|
|`--management-network-ip`|[Configure the Management Network](mgmt_network.md#static-ip)|
|`--memory`|[Virtual Container Host Compute Capacity](vch_compute.md#memory)|
|`--memory-reservation`|[Virtual Container Host Compute Capacity](vch_compute.md#memoryres)|
|`--memory-shares`|[Virtual Container Host Compute Capacity](vch_compute.md#memoryshares)|
|`--name`|[General Virtual Container Host Settings](vch_general_settings.md#name)|
|`--no-proxy`|[Configure VCHs to Use Proxy Servers](vch_proxy.md#noproxy)|
|`--no-tls`|[Disable Client Verification](tls_unrestricted.md#no-tls)|
|`--no-tlsverify`|[Disable Client Verification](tls_unrestricted.md#no-tlsverify)|
|`--ops-grant-perms`|[Configure the Operations User](set_up_ops_user.md#perms)|
|`--ops-password`|[Configure the Operations User](set_up_ops_user.md#credentials)|
|`--ops-user`|[Configure the Operations User](set_up_ops_user.md)|
|`--organization`|[Virtual Container Host Certificate Options](vch_cert_options.md#org)|
|`--password`|[Basic `vic-machine create` Options](using_vicmachine.md#password)|
|`--public-network`|[Configure the Public Network](public_network.md)|
|`--public-network-gateway`|[Configure the Public Network](public_network.md#gateway)|
|`--public-network-ip`|[Configure the Public Network](public_network.md#static-ip)|
|`--registry-ca`|[Configure Registry Access](vch_registry.md#registry-ca)|
|`--storage-quota`|[Specify the Image Datastore](image_store.md#quota)|
|`--syslog-address`|[General Virtual Container Host Settings](vch_general_settings.md#syslog)|
|`--target`|[Basic `vic-machine create` Options](using_vicmachine.md#target)|
|`--thumbprint`|[Basic `vic-machine create` Options](using_vicmachine.md#thumbprint)|
|`--timeout`|[Basic `vic-machine create` Options](using_vicmachine.md#timeout)|
|`--tls-ca`|[Virtual Container Host Certificate Options](vch_cert_options.md#ca-pem)|
|`--tls-cert-path`|[Virtual Container Host Certificate Options](vch_cert_options.md#cert-path)|
|`--tls-cname`|[Virtual Container Host Certificate Options](vch_cert_options.md#tls-cname)|
|`--tls-server-cert`|[Virtual Container Host Certificate Options](vch_cert_options.md#server-cert)|
|`--tls-server-key`|[Virtual Container Host Certificate Options](vch_cert_options.md#server-key)|
|`--user`|[Basic `vic-machine create` Options](using_vicmachine.md#user)|
|`--volume-store`|[Specify Volume Datastores](volume_stores.md)|
|`--whitelist-registry`|[Configure Registry Access](vch_registry.md#whitelist-registry)|

## `vic-machine configure` Options <a id="configure"></a>

|**Option**|**Documentation**|  
|---|---|
|`--affinity-vm-group`|[Update Affinity Group Settings](configure_vch.md#affinity)|
|`--compute-resource`|[Common `vic-machine` Options](common_vic_options.md#compute-resource)|
|`--container-network`|[Configure Container Network Settings](configure_vch.md#containernet)|
|`--container-network-dns`|[Configure Container Network Settings](configure_vch.md#containernet)|
|`--container-network-firewall`|[Configure Container Network Settings](configure_vch.md#containernet)|
|`--container-network-gateway`|[Configure Container Network Settings](configure_vch.md#containernet)|
|`--container-network-ip-range`|[Configure Container Network Settings](configure_vch.md#containernet)|
|`--containers`|[Set or Update Container VM Limit](configure_vch.md#container-limit)|
|`--cpu`|[Configure CPU and Memory Allocations](configure_vch.md#cpumem)|
|`--cpu-reservation`|[Configure CPU and Memory Allocations](configure_vch.md#cpumem)|
|`--cpu-shares`|[Configure CPU and Memory Allocations](configure_vch.md#cpumem)|
|`--debug`|[Configure Debug Mode](configure_vch.md#debug)|
|`--dns-server`|[Add and Reset DNS Servers](configure_vch.md#dns)|
|`--force`|[Using `vic-machine configure`](configure_vch.md#using)|
|`--http-proxy`|[Add, Configure, or Remove Proxy Servers](configure_vch.md#proxies)|
|`--https-proxy`|[Add, Configure, or Remove Proxy Servers](configure_vch.md#proxies)|
|`--id`|[Common `vic-machine` Options](common_vic_options.md#id)|
|`--memory`|[Configure CPU and Memory Allocations](configure_vch.md#cpumem)|
|`--memory-reservation`|[Configure CPU and Memory Allocations](configure_vch.md#cpumem)|
|`--memory-shares`|[Configure CPU and Memory Allocations](configure_vch.md#cpumem)|
|`--name`|[Common `vic-machine` Options](common_vic_options.md#name)|
|`--no-tlsverify`|[Update Security Configuration](configure_vch.md#tlscerts)|
|`--ops-grant-perms`|[Update vCenter Server Credentials](configure_vch.md#vccreds)|
|`--ops-password`|[Update vCenter Server Credentials](configure_vch.md#vccreds)|
|`--ops-user`|[Update vCenter Server Credentials](configure_vch.md#vccreds)|
|`--password`|[Common `vic-machine` Options](common_vic_options.md#password)|
|`--registry-ca value`|[Add or Update Registry Server Certificates](configure_vch.md#registries)|
|`--reset-progress`|[Reset Upgrade or Configuration Progress](configure_vch.md#resetprogress)|
|`--storage-quota`|[Set or Update Storage Quotas](configure_vch.md#quota)|
|`--target`|[Common `vic-machine` Options](common_vic_options.md#target)|
|`--thumbprint`|[Common `vic-machine` Options](common_vic_options.md#thumbprint)|
|`--timeout`|[Common `vic-machine` Options](common_vic_options.md#timeout)|
|`--tls-cert-path`|[Update Security Configuration](configure_vch.md#tlscerts)|
|`--tls-cname`|[Update Security Configuration](configure_vch.md#tlscerts)|
|`--tls-server-cert`|[Update Security Configuration](configure_vch.md#tlscerts)|
|`--tls-server-key`|[Update Security Configuration](configure_vch.md#tlscerts)|
|`--user`|[Common `vic-machine` Options](common_vic_options.md#user)|
|`--volume-store`|[Add Volume Stores](configure_vch.md#volumes)|

## `vic-machine debug` Options <a id="debug"></a>

|**Option**|**Documentation**|  
|---|---|
|`--authorized-key`|[Authorize SSH Access to the VCH Endpoint VM](vch_ssh_access.md)|
|`--compute-resource`|[Common `vic-machine` Options](common_vic_options.md#compute-resource)|
|`--enable-ssh`|[Authorize SSH Access to the VCH Endpoint VM](vch_ssh_access.md)|
|`--id`|[Common `vic-machine` Options](common_vic_options.md#id)|
|`--name`|[Common `vic-machine` Options](common_vic_options.md#name)|
|`--password`|[Common `vic-machine` Options](common_vic_options.md#password)|
|`--rootpw`|[Enable shell access to the VCH Endpoint VM](vch_shell_access.md)|
|`--target`|[Common `vic-machine` Options](common_vic_options.md#target)|
|`--thumbprint`|[Common `vic-machine` Options](common_vic_options.md#thumbprint)|
|`--timeout`|[Common `vic-machine` Options](common_vic_options.md#timeout)|
|`--user`|[Common `vic-machine` Options](common_vic_options.md#user)|

## `vic-machine delete` Options <a id="delete"></a>

|**Option**|**Documentation**|  
|---|---|
|`--compute-resource`|[Common `vic-machine` Options](common_vic_options.md#compute-resource)|
|`--force`|[Delete Virtual Container Hosts](remove_vch.md)|
|`--id`|[Common `vic-machine` Options](common_vic_options.md#id)|
|`--name`|[Common `vic-machine` Options](common_vic_options.md#name)|
|`--password`|[Common `vic-machine` Options](common_vic_options.md#password)|
|`--target`|[Common `vic-machine` Options](common_vic_options.md#target)|
|`--thumbprint`|[Common `vic-machine` Options](common_vic_options.md#thumbprint)|
|`--timeout`|[Common `vic-machine` Options](common_vic_options.md#timeout)|
|`--user`|[Common `vic-machine` Options](common_vic_options.md#user)|

## `vic-machine inspect` Options <a id="inspect"></a>

|**Option**|**Documentation**|  
|---|---|
|`--compute-resource`|[Common `vic-machine` Options](common_vic_options.md#compute-resource)|
|`--id`|[Common `vic-machine` Options](common_vic_options.md#id)|
|`--name`|[Common `vic-machine` Options](common_vic_options.md#name)|
|`--password`|[Common `vic-machine` Options](common_vic_options.md#password)|
|`--target`|[Common `vic-machine` Options](common_vic_options.md#target)|
|`--thumbprint`|[Common `vic-machine` Options](common_vic_options.md#thumbprint)|
|`--timeout`|[Common `vic-machine` Options](common_vic_options.md#timeout)|
|`--tls-cert-path`|[Obtain General Virtual Container Host Information and Connection Details](inspect_vch.md)|
|`--user`|[Common `vic-machine` Options](common_vic_options.md#user)|

## `vic-machine inspect config` Options <a id="inspect-config"></a>

|**Option**|**Documentation**|  
|---|---|
|`--compute-resource`|[Common `vic-machine` Options](common_vic_options.md#compute-resource)|
|`--id`|[Common `vic-machine` Options](common_vic_options.md#id)|
|`--format`|[Obtain Virtual Container Host Configuration Information](inspect_vch_config.md)|
|`--name`|[Common `vic-machine` Options](common_vic_options.md#name)|
|`--password`|[Common `vic-machine` Options](common_vic_options.md#password)|
|`--target`|[Common `vic-machine` Options](common_vic_options.md#target)|
|`--thumbprint`|[Common `vic-machine` Options](common_vic_options.md#thumbprint)|
|`--timeout`|[Common `vic-machine` Options](common_vic_options.md#timeout)|
|`--tls-cert-path`|[Obtain General Virtual Container Host Information and Connection Details](inspect_vch.md)|
|`--user`|[Common `vic-machine` Options](common_vic_options.md#user)|

## `vic-machine ls` Options <a id="ls"></a>

|**Option**|**Documentation**|  
|---|---|
|`--password`|[Common `vic-machine` Options](common_vic_options.md#password)|
|`--target`|[Common `vic-machine` Options](common_vic_options.md#target)|
|`--timeout`|[Common `vic-machine` Options](common_vic_options.md#timeout)|
|`--thumbprint`|[Common `vic-machine` Options](common_vic_options.md#thumbprint)|
|`--user`|[Common `vic-machine` Options](common_vic_options.md#user)|

## `vic-machine update firewall` Options <a id="update"></a>

|**Option**|**Documentation**|  
|---|---|
|`--allow`|[Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md)|
|`--compute-resource`|[Common `vic-machine` Options](common_vic_options.md#compute-resource)|
|`--deny`|[Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md)|
|`--password`|[Common `vic-machine` Options](common_vic_options.md#password)|
|`--target`|[Common `vic-machine` Options](common_vic_options.md#target)|
|`--thumbprint`|[Common `vic-machine` Options](common_vic_options.md#thumbprint)|
|`--timeout`|[Common `vic-machine` Options](common_vic_options.md#timeout)|
|`--user`|[Common `vic-machine` Options](common_vic_options.md#user)|

## `vic-machine upgrade` Options <a id="upgrade"></a>

|**Option**|**Documentation**|  
|---|---|
|`--appliance-iso`|[VCH Upgrade Options](upgrade_vch_options.md#appliance-iso)|
|`--bootstrap-iso`|[VCH Upgrade Options](upgrade_vch_options.md#bootstrap-iso)|
|`--compute-resource`|[Common `vic-machine` Options](common_vic_options.md#compute-resource)|
|`--debug`|[VCH Upgrade Options](upgrade_vch_options.md#debug)|
|`--force`|[VCH Upgrade Options](upgrade_vch_options.md#force)|
|`--id`|[Common `vic-machine` Options](common_vic_options.md#id)|
|`--name`|[Common `vic-machine` Options](common_vic_options.md#name)|
|`--password`|[Common `vic-machine` Options](common_vic_options.md#password)|
|`--reset-progress`|[VCH Upgrade Options](upgrade_vch_options.md#reset-progress)|
|`--rollback`|[VCH Upgrade Options](upgrade_vch_options.md#rollback)|
|`--target`|[Common `vic-machine` Options](common_vic_options.md#target)|
|`--thumbprint`|[Common `vic-machine` Options](common_vic_options.md#thumbprint)|
|`--timeout`|[Common `vic-machine` Options](common_vic_options.md#timeout)|
|`--user`|[Common `vic-machine` Options](common_vic_options.md#user)|

## `vic-machine version` Options <a id="version"></a>

The `vic-machine version` command has no options.