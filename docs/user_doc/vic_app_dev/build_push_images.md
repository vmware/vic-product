# Using `dch-photon` to Build and Push Images

The current version of vSphere Integrated Containers Engine does not support `docker build` or `docker push`. As a consequence, the workflow for developing container images and pushing them to a registry server is slightly different to the workflow in a regular Docker environment.

- You use standard Docker to build, tag, and push a container image to a registry.
- You pull the image from the registry to a vSphere Integrated Containers virtual container host (VCH) to use it.

 This release of vSphere Integrated Containers includes an image repository named `dch-photon`, that is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. The `dch-photon` image allows you to deploy containers that run a standard Docker engine in a Photon OS container. You can then use this Docker engine to perform `docker build` or `docker push` operations.

This topic provides an example of using `dch-photon` to push an image to vSphere Integrated Containers Registry and then pull it into a VCH. For simplicity, the example uses the `busybox` container image instead of building a new image. 

**Prerequisites**
- You have access to an image repository. For example, a project repository must exist in vSphere Integrated Containers Registry and you must have a user account that can access that project repository.
- Configure your Docker client to use the vSphere Integrated Containers Registry certificate. For information about how to pass the registry certificate to the Docker client, see [Using vSphere Integrated Containers Registry](configure_docker_client.md#registry) in Configure the Docker Client for Use with vSphere Integrated Containers.
- You have access to a VCH that the vSphere administrator configured so that it can connect to the registry. For information about how deploy a VCH so that it can access a private registry, see the [Private Registry Options](../vic_vsphere_admin/vch_installer_options.md#registry) section of VCH Deployment Options and [Deploy a VCH for Use with vSphere Integrated Containers Registry](../vic_vsphere_admin/deploy_vch_registry.md) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*
- In the example, connections to the registry are secured by TLS, but for simplicity the connection between the Docker client and the VCH is not. As a consequence, the Docker commands to run in the VCH do not include any TLS options. If your VCH uses TLS authentication, adapt the Docker commands accordingly, and use port 2376 instead of 2375 when connecting to the VCH. For information about how to connect a Docker client to a VCH that uses TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.  

**Procedure**

1. Pull the `busybox` container image from Docker Hub.<pre>docker pull busybox</pre>In a real-world scenario you would build a new container image rather than pulling the `busybox` image.
2. Tag the image for uploading to the appropriate project repository in vSphere Integrated Containers Registry.<pre>docker tag busybox:1.26 <i>registry_address</i>/<i>project_name</i>/busybox:1.26 </pre>If vSphere Integrated Containers Registry listens for connections on a non-default port, include the port number in the registry address.
3. Log in to vSphere Integrated Containers Registry.<pre>docker login <i>registry_address</i></pre>
3. Push the image from the standard Docker host to vSphere Integrated Containers Registry.<pre>docker push <i>registry_address</i>/<i>project_name</i>/busybox:1.26 </pre>
5. Pull the image from vSphere Integrated Containers Registry into the VCH.<pre>docker -H <i>vch_address</i>:2375 pull <i>registry_address</i>/<i>project_name</i>/busybox:1.26 </pre>
6. List the images that are running in your VCH.<pre>docker -H <i>vch_address</i>:2375 images</pre>

**Result**

The image that you pulled from vSphere Integrated Containers Registry appears in the list of images that are available in this VCH.
<pre>
REPOSITORY                                    TAG          IMAGE ID            
<i>registry_address</i>/<i>project_name</i>/busybox    1.26         7e156d496c9f</pre>
