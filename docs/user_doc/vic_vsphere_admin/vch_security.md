# Virtual Container Host Security #

The security options that `vic-machine create` provides allow for 3 broad categories of security:

- [Restrict access to the Docker API with Auto-Generated Certificates](tls_auto_certs.md)
- [Restrict access to the Docker API with Custom Certificates](tls_custom_certs.md)
- [Do Not Restrict Access to the Docker API](tls_unrestricted.md)
- [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

**NOTE**: Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.