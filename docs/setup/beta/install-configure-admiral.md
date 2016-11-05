### Installing Admiral

Now that we have our [VCH up and running](install-configure-vch.md), we are going to instantiate Admiral as a containerVM using VCH1 as our end-point.

#### Preparing the Admiral installation
The Admiral bits are available on [docker hub](https://hub.docker.com/r/vmware/admiral/).

#### Installation procedure for Admiral
We assume you are on your client machine and your `DOCKER_HOST` (and `DOCKER_API_VERSION` if needed) variables are properly set to connect to the VCH. If not, set them again:
```
export DOCKER_HOST=tcp://10.140.51.101:2375
export DOCKER_API_VERSION=1.23  
```
This is the command we are using to instantiate Admiral:

```
root@photonOSvm1 [ ~ ]# docker run -d -p 8282:8282 --name admiral vmware/admiral
676c060aa2595b7d3c4758887e4cce66adfe3b7f5f56d26eb71567f0595db534
```
Admiral is now running as a VM inside the Virtual Container Host in vSphere and is exposed on port 8282. This is the complete URL you need to point your browser to: http://10.140.51.101:8282 (where 10.140.51.101 is the IP of the VCH1 Endpoint VM).

The VCH proxy VM is NATting port 8282 to port 8282 of the containerVM that is running the Admiral service.   

Congratulations! You have just deployed Admiral successfully!

### Adding a Harbor instance to Admiral

Admiral supports adding additional registries to the default registry set (registry.hub.docker.com).

To manage registries, you need to go to the Templates tab and click ***Manage Registry***.

If you click ***Add***, you can add additional registries.

Now we are going to add the Harbor instance we just deployed by giving it a name and filling the IP / Hostname field with `http://10.140.50.77:80`.

As a reminder, we have [deployed the Harbor appliance](install-configure-harbor.md) and customized with the 10.140.50.77 IP. Make sure you specify port 80 when you enter the IP address because Admiral will otherwise default to port 5000 for registries. Make sure also to specify http. Leaving this out will try to connect using https and fail.

We are also going to define new credentials in Admiral to match the credentials for the admin user in Harbor (admin/Harbor12345) when we add Harbor as an additional registry.

If everything worked, you should now see two registries listed and available: docker hub and the harbor registry.

### Adding a VCH to Admiral

Here we are going to Add the VIC Virtual Container Host that we deployed [previously](install-configure-vch.md) (VCH1). This way you will be able to deploy, from the Admiral portal, your own workloads against the VCH1 endpoint.  

This is how we do that:

- Move to the Hosts tab and click ***Add***.

- Specify `https://10.140.51.101:2375` as your Docker host IP address (10.140.51.101 is the IP of the VCH1 Endpoint VM).

- Since we have instantiate the VCH with the `--no-tls` flag, there is no need to configure the credentials. Should you have instantiated it with proper certificates you would have needed to configure the certificates based credentials in Admiral before connecting to the VCH.

- For now, in the Resource Pool field you can select the default-resource-pool and leave all the other fields empty.

- When you Add the VCH Admiral will inform you that the certificate isn’t trusted. Just click yes.

If everything worked fine, you should now see a new host (the VCH). This new host is running, at the very least, one container: this is the Admiral image we instantiated against VCH1 itself. In addition you may be seeing other containers running from the previous tests in the [previous steps](install-configure-vch.md) (e.g. nginx ).

Congratulations! You have added your VCH to Admiral
