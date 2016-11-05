
### Preparing the Harbor installation

Setting up up Harbor is pretty straightforward. Harbor is shipped as a virtual appliance.

We will instantiate Harbor on the same vSphere infrastructure that will host the VCH as well as the containerVMs.

You can grab the OVA file from [here](https://github.com/vmware/harbor/releases/download/0.4.5/harbor_0.4.5_beta_respin2.ova). If you need more information on this release please see [here](https://github.com/vmware/harbor/releases/tag/0.4.5).

### Installation procedure for Harbor

The OVA supports deployments by either using a fixed IP or an IP from a DHCP. To set a fixed IP fill out entirely the OVF properties when prompted. For a DHCP deployment, do not fill out the networking related OVF properties.

In addition, the Harbor appliance also provides OVF properties to configure the AD/LDAP integration.

OVA deployments have been tested with the following tools:
- vSphere Web Client
- vSphere C# Client
- ovftool


Please refer to [this document](https://github.com/vmware/harbor/blob/master/docs/installation_guide_ova.md) for more information about how to properly install the Harbor OVA. 

For reference, the following is a working example (run from a Mac) of an ovftool syntax that sets a fixed IP address (10.140.50.77). Note that before you can run the command below you must have extracted the OVF and VMDK files from the OVA.

```
"/Applications/VMware OVF Tool/ovftool" harbor_0.4.5_beta_respin2.ova harbor_0.4.5_beta_respin2.ovf

"/Applications/VMware OVF Tool/ovftool" --datastore=vsan-lab --name=harbor1 --net:"Network 1"="vds10g-lab-506-vmnet-eph" --diskMode=thin --powerOn --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:vami.domain.Harbor=mgmt.local --prop:vami.searchpath.Harbor=mgmt.local --prop:vami.DNS.Harbor=8.8.8.8 --prop:vami.ip0.Harbor=10.140.50.77 --prop:vami.netmask0.Harbor=255.255.255.0 --prop:vami.gateway.Harbor=10.140.50.254 --prop:vm.vmname=Harbor harbor_0.4.5_beta_respin2.ovf 'vi://mreferre@vmware.com:xxxxxx@msbu-vc-lab.mgmt.local/Home/host/Cluster1/10.140.50.11'
```
***Note `msbu-vc-lab.mgmt.local` is the FQDN of the vCenter server and `10.140.50.11` is the IP of an ESX host inside `Cluster1`. `Home` is the name of the vSphere Datacenter where `Cluster1` resides. Also note that in this example we are not filling the AD/LDAP properties which means we are not configuring the integration on this appliance being deployed. Additional OVF properties should be set to configure AD/LDAP integration***

If everything worked, you should point the browser to the Linux VM (in this case 10.140.50.77) on port 80 and see the Harbor portal. Port 80 is the port that the Harbor frontend component is exposed on.

Now you can login using _admin_ and the default password (_Harbor12345_). You can optionally change this password if you want to.

Among the many features Harbor provides, there is also RBAC support.

The Admin has the capability to create additional users in the system. There is no support for groups at the moment. These users can be given Admin privileges or they can just be regular users.

All users have the capability to create Projects and the project owner (who created it) can provide access level to existing users to specific projects (unless the user creates a public project, at which point everyone can see it without requiring any login).   

For the purpose of our next [exercise](using-harbor.md) you will need to:

- create 2 users: jane and mark
- create a private project called vmworld
- give mark “developer” access to the vmworld project (you will not explicitly allow jane to access it)

Mark will now be able to push and pull to and from the vmworld project.
