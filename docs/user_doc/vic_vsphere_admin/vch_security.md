# Virtual Container Host Security #

Virtual container hosts (VCHs) authenticate connections from Docker API clients by using server and client TLS certificates. For information about how VCHs and Docker use certificates, see [Virtual Container Host Certificate Requirements](vch_cert_reqs.md). 

When you deploy a VCH, you can use all automatically generated certificates, all custom certificates, or a combination of both. 

**NOTE**: The Create Virtual Container Host wizard in the vSphere Client does not support automatically generated CA or client certificates. To use automatically generated CA and client certificates, you must use the `vic-machine` CLI utility to deploy VCHs.

The following table provides a summary of the configurations that vSphere Integrated Containers Engine supports, and whether you can implement those configurations in the Create Virtual Container Host wizard in the vSphere Client.

|**Configuration**|**Available in vSphere Client?**|**Examples**|
|---|---|
|Auto-generated server certificate + auto-generated CA + auto-generated client certificate|No|[Example](vch_cert_options.md#full-auto)|
|Auto-generated server certificate + custom CA|Yes|[Example](vch_cert_options.md#auto-server)|
|Custom server certificate + custom CA|Yes|[Example](vch_cert_options.md#all-custom)|
|Custom server certificate + auto-generated CA + auto-generated client certificate|No|[Example](vch_cert_options.md#custom-server-auto-client-ca)|
|Auto-generated server certificate + no client verification|Yes|[Example](tls_unrestricted.md#auto-notlsverify)|
|Custom server certificate + no client verification|Yes|[Example](tls_unrestricted.md#custom_notlsverify)|
|No server or client certificate verification|No|[Example](tls_unrestricted.md#example_no-tls)|

The following topics describe how to achieve all of the configurations listed in the table above, by using either the Create Virtual Container Host wizard or the `vic-machine` CLI, or both. 

- [Virtual Container Host Certificate Options](vch_cert_options.md)
- [Disable Client Verification](tls_unrestricted.md)

The Examples column in the table provides direct links to the relevant example in these topics.