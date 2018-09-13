# Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates

If you do not provide custom certificates during deployment, the OVA installer generates certificates for the vSphere Integrated Containers Management Portal and the vSphere Integrated Containers file server. These certificates authenticate connections to the appliance welcome page, vSphere Integrated Containers Management Portal, and the vSphere Integrated Containers Engine bundle and vSphere Client plug-in downloads. If you deploy the appliance with automatically generated certificates, the certificates are self-signed by an automatically generated Certificate Authority (CA).

The vSphere administrator obtains the thumbprints and CA files and passes them to other users who need to access the appliance welcome page or the vSphere Integrated Containers Management Portal. 

**Procedure**

1. Use SSH to connect to the vSphere Integrated Containers appliance as `root` user.<pre>$ ssh root@<i>vic_appliance_address</i></pre>
2. Use `openssl` to view the certificate fingerprint of the file server. 

    The file server certificate authenticates access to the appliance welcome page, including the downloads for the vSphere Integrated Containers Engine bundle and the vSphere Client plug-in. 

    <pre>openssl x509 -in  /opt/vmware/fileserver/cert/server.crt -noout -sha1 -fingerprint</pre>

2. Use `openssl` to view the certificate fingerprint of the management portal. 

    The management portal certificate authenticates access to the vSphere Integrated Containers Management Portal. 

    <pre>openssl x509 -in  /data/admiral/cert/server.crt -noout -sha1 -fingerprint</pre>

3. Take a note of the two thumbprints and close the SSH session.
4. Use `scp` to copy the CA file for the file server to your local machine.

    <pre>scp root@<i>vic_appliance_address</i>:/opt/vmware/fileserver/cert/ca.crt <i>/path/on/local_machine/folder1</i></pre>

5. Use `scp` to copy the CA file for the management portal to your local machine.

    <pre>scp root@<i>vic_appliance_address</i>:/data/admiral/cert/ca.crt <i>/path/on/local_machine/folder2</i></pre>

     Be sure to copy the two files to different locations, as they are both named `ca.crt`.
  
You can share the thumbprints and CA files with users who need to connect to the vSphere Integrated Containers Management Portal or downloads. For information about how to verify the thumbprints and trust  the CAs, see [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).
