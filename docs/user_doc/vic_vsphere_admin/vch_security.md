# Virtual Container Host Security #

VCHs authenticate Docker API client connections by using client certificates. This configuration is commonly referred to as `tlsverify` in documentation about containers and Docker. When you deploy a VCH, you must specify the level of security that applies to connections from Docker clients to the Docker API endpoint that is running in the VCH. The security options that `vic-machine create` provides allow for three broad categories of VCH client security:

- [Restrict Access to the Docker API with Auto-Generated Certificates](tls_auto_certs.md)
- [Restrict Access to the Docker API with Custom Certificates](tls_custom_certs.md)
- [Unrestricted Access to the Docker API](tls_unrestricted.md)

You must run all `vic-machine` commands with a vSphere administrator account. However, you can configure a VCH so that it uses an account with reduced privileges for post-deployment operation, instead of using the vSphere administrator account. For information about using a separate account for post-deployment operation, [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

