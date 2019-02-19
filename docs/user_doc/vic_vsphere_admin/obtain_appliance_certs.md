# Obtain the Thumbprint and CA File of the vSphere Integrated Containers Appliance Certificate

If you do not provide custom certificates during deployment, the OVA installer generates a single certificate for the vSphere Integrated Containers Management Portal and the vSphere Integrated Containers file server. This certificate authenticates connections to the appliance welcome page, vSphere Integrated Containers Management Portal, the vSphere Integrated Containers Engine bundle, and the vSphere Client plug-in downloads. If you deploy the appliance with an automatically generated certificate, the certificate is self-signed by an automatically generated Certificate Authority (CA).

The vSphere administrator can obtain the thumbprint and CA file and passes them to other users who need to access the appliance welcome page or the vSphere Integrated Containers Management Portal. 

## Procedure

1. Use SSH to connect to the vSphere Integrated Containers appliance as `root` user.<pre>$ ssh root@<i>vic_appliance_address</i></pre>
2. Use `openssl` to view the certificate fingerprint. 

    <pre>openssl x509 -in /storage/data/certs/server.crt -noout -sha1 -fingerprint</pre>

3. Take a note of the thumbprint and close the SSH session.
4. Use `scp` to copy the CA file to your local machine.

    <pre>scp root@<i>vic_appliance_address</i>:/opt/vmware/fileserver/cert/ca.crt <i>/path/on/local_machine/folder1</i></pre>
  
You can share the thumbprint and CA file with users who need to connect to the vSphere Integrated Containers Management Portal or downloads. For information about how to verify the thumbprint and trust the CA, see [Verify and Trust the vSphere Integrated Containers Appliance Certificate](../vic_cloud_admin/trust_vic_certs.md).