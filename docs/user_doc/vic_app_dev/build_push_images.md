# Building and Pushing Images with the `dch-photon` Docker Engine 

vSphere Integrated Containers Engine is an enterprise container runtime that you use as a deployment endpoint for container VMs. As such, it does not have native `docker build` or `docker push` capabilities. The job of building and pushing container images is typically part of a continuous integration (CI) pipeline, that does this by using standard Docker Engine instances. 

vSphere Integrated Containers can deploy standard Docker Engine instances for you, in the form of a container image repository named `dch-photon`.  The `dch-photon` image allows you to deploy container VMs that run a Docker Engine instance, known as a Docker container host (DCH), that runs on [Photon OS](https://vmware.github.io/photon/). You can deploy any number of these `dch-photon` Docker Engine instances to perform `docker build` and `docker push` operations as part of your CI infrastructure. 

vSphere Integrated Containers 1.4.x supports `dch-photon` version 1.13. The `dch-photon` image is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. 

- [Advantages of Using `dch-photon`](#advantages)
- [Requirements for Using `dch-photon`](#requirements)
  - [Anonymous `dch-photon` Volumes](#vols) 
- [Using `dch-photon` with vSphere Integrated Containers Registry](#registry)
- [What to Do Next](#procedure)

## Advantages of Using `dch-photon` <a id="advantages"></a> 

Virtual container hosts (VCHs) focus on running pre-existing images in production. An advantage of using VCHs  over standard Docker Engine instances is the opinionated, strongly isolated provisioning model of container VMs as compared to standard containers. VCHs assume that image creation happens elsewhere in the CI process. vSphere Integrated Containers provides the `dch-photon` Docker Engine as a container image so that you can easily deploy Docker Engine instances to act as build slaves in your CI infrastructure.  

By bringing the ephemeral quality of running the container host itself as a container VM, `dch-photon` provides the following advantages:

- Eliminates snowflake deployments of Docker Engine.
- Promotes efficient use of resources by providing an easy mechanism for provisioning and removing container engine instances that fits well with CI automation.

The workflow for using `dch-photon` Docker Engines is as follows: 

1. Pull the `dch-photon` image from vSphere Integrated Containers Registry and instantiate it.
2. Use the Docker Engine running in `dch-photon` to build and push an image to vSphere Integrated Containers Registry.
3. Remove the `dch-photon` container.
4. Pull the new image from vSphere Integrated Containers Registry into a VCH and run it in production.

Because of the ephemeral quality of the `dch-photon` Docker Engine and because it is itself a container image, this process can be scripted or integrated with an existing CI tool, such as Jenkins.

## Requirements for Using `dch-photon` <a id="requirements"></a>

To use `dch-photon`, your environment must satisfy the following conditions: 

- Configure your local Docker client to use the vSphere Integrated Containers Registry certificate. For information about how to obtain the registry certificate and pass it to the Docker client, see [Using vSphere Integrated Containers Registry](configure_docker_client.md#registry).
- You have access to a VCH that the vSphere administrator configured so that it can connect to the registry to pull the `dch-photon` image. The VCH must also have a volume store named `default`. For information about how deploy a VCH that is suitable for use with `dch-photon`, see the [Deploy a Virtual Container Host with a Volume Store and vSphere Integrated Containers Registry Access](../vic_vsphere_admin/deploy_vch_dchphoton.md) in *vSphere Integrated Containers for vSphere Administrators*. 

### Anonymous `dch-photon` Volumes <a id="vols"></a>

Each `dch-photon` container VM that you run creates an anonymous volume in the `default` volume store. By default, all of the images you pull into `dch-photon` go into this volume. The anonymous volume has a 2 GB limit. If you require more than 2 GB to store images and container state, you must explicitly specify a volume with a higher limit when you run `dch-photon`. 

The anonymous volumes that `dch-photon` creates are not deleted when you delete a `dch-photon` container VM.  This is by design, so that you can persist your image cache and container state beyond the lifespan of an individual `dch-photon` container VM. When you delete `dch-photon` container VMs, you must manually remove the anonymous volume from the volume store if you do not require them.

## Using `dch-photon` with vSphere Integrated Containers Registry <a id="registry"></a>

For `dch-photon` to be able to authenticate with vSphere Integrated Containers Registry, it needs to have the registry's CA certificate. 
The purpose of `dch-photon` is primarily to build images and push them to registries, so each `dch-photon` instance must be able to authenticate with the registry to which it pushes. Even if you use the same Docker client to pull and run the `dch-photon` image as you use to push built images back to the registry, the `dch-photon` container VM still needs to have the appropriate registry certificate so that it can successfully push images. 

You can provide the certificate to `dch-photon` in one of two ways:

-  Build a custom `dch-photon` image that has the certificate embedded in it. This method is preferable since you only need to perform the operation once.
-  Manually copy the certificate in to a `dch-photon` container running in a VCH by using `docker cp`.

When you have deployed `dch-photon` with the registry certificate, you can use it to build an image and push that image from `dch-photon` to vSphere Integrated Containers Registry. You can then pull the image from the registry into a VCH for deployment. 

## What to Do Next <a id="procedure"></a>

To use `dch-photon` with vSphere Integrated Containers Registry and a VCH, you must perform the following tasks, in order:

1. Obtain an appropriately configured VCH by following the procedure in [Deploy a Virtual Container Host with a Volume Store and vSphere Integrated Containers Registry Access](../vic_vsphere_admin/deploy_vch_dchphoton.md).
2. Provide the vSphere Integrated Containers Registry certificate to a `dch-photon` instance in one of the following ways:

  - [Add the Registry Certificate to a Custom  `dch-photon`  Image](photon_cert_custom.md)
  - [Manually Add the Registry Certificate to a `dch-photon` VM](photon_cert_manual.md)
2. Test the dch-photon instance by following the procedure in [Build, Push, and Pull an Image with `dch-photon`](test_photon.md).

## Advanced Use of `dch-photon`

For information about how to use `dch-photon` with TLS authentication and with other registries than vSphere Integrated Containers Registry, see [Advanced dch-photon Deployment](dchphoton_options.md).

For information about to use `dch-photon` large images or large numbers of images, see [Expand the Root Disk on a dch-photon Docker Engine](dch_expand_disk.md).

For information about configuring `dch-photon` to use proxy servers, see [Configure `dch-photon` to Use Proxy Servers](dch_photon_proxy.md).

For information about configuring `dch-photon` to connect to registries that use a custom CA, see [Add a Custom Registry Certificate Authority to `dch-photon`](add_custom_ca.md).

For information about instantiating a Docker swarm, see [Automating Swarm Creation with vSphere Integrated Containers](https://blogs.vmware.com/cloudnative/2017/10/03/automating-swarm-creation-with-vic-1-2/).

**NOTE**: Using `dch-photon` to instantiate Docker swarm is not officially supported.