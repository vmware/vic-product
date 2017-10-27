# Virtual Container Host Deployment Options

You use the `vic-machine create` command to deploy virtual container hosts (VCHs).

The `vic-machine create` command provides many options that allow you to customize the deployment of virtual container hosts (VCHs) to correspond to your vSphere environment and to meet your development requirements. The following sections present the `vic-machine create` options, grouped by subject matter.

- [Virtual Container Host Placement](vch_placement.md)
- [Virtual Container Host Security](vch_security.md)
- [Virtual Container Host Networking](vch_networking.md)
- [Virtual Container Host Storage](vch_storage.md)
- [Connect Virtual Container Hosts to Registries](vch_registry.md)
- [VCH Configuration](vch_config.md)
- [Container VM Configuration](containervm_config.md)
- [Virtual Container Host Debugging](vic_vsphere_admin/vch_debug.md)

## Specifying Option Arguments ##

When you run `vic-machine` commands, wrap any option arguments that include spaces or special characters in quotes. Use single quotes if you are using `vic-machine` on a Linux or Mac OS system and double quotes on a Windows system. 

Option arguments that might require quotation marks include the following:

- User names and passwords in `--target`, or in `--user` and `--password`.
- Datacenter names in `--target`.
- VCH names in `--name`.
- Datastore names and paths in `--image-store` and `--volume-store`.
- Network and port group names in all networking options.
- Cluster and resource pool names in `--compute-resource`.
- Folder names in the paths for `--tls-cert-path`, `--tls-server-cert`, `--tls-server-key`, `--appliance-iso`, and `--bootstrap-iso`.
