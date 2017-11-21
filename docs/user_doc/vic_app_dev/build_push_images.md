# Building and Pushing Images with the `dch-photon` Docker Engine 

vSphere Integrated Containers Engine is an enterprise container runtime that you use as a deployment endpoint. As such, it does not have native `docker build` or `docker push` capabilities. The job of building and pushing container images is typically part of a continuous integration (CI) pipeline which does this by using standard Docker Engine instances. 

- You use standard Docker Engine to build, tag, and push a container image to a registry.
- You pull the image from the registry to a vSphere Integrated Containers virtual container host (VCH) to deploy it.

vSphere Integrated Containers Engine can deploy Docker Engine instances for you, in the form of a container image repository named `dch-photon`. This image is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. The `dch-photon` image allows you to deploy a container VM that runs a Docker Engine instance hosted in Photon OS. You can deploy any number of these Docker Engine instances to perform `docker build` and `docker push` operations as part of your CI infrastructure. 

- [Requirements for Using `dch-photon`](#requirements)
  - [Anonymous `dch-photon` Volumes](#vols) 
- [Using `dch-photon` with vSphere Integrated Containers Registry](#registry)
- [Using `dch-photon` with Other Registries](#other)
- [Instantiating Docker Swarms with `dch-photon`](#swarm)

## Requirements for Using `dch-photon` <a id="requirements"></a>

To use `dch-photon`, your environment must satisfy the following conditions: 

- Configure your local Docker client to use the vSphere Integrated Containers Registry certificate. For information about how to obtain the registry certificate and pass it to the Docker client, see [Using vSphere Integrated Containers Registry](configure_docker_client.md#registry).
- You have access to a VCH that the vSphere administrator configured so that it can connect to the registry to pull the `dch-photon` image. The VCH must also have a volume store named `default`. For information about how deploy a VCH for use with `dch-photon`, see the [Deploy a Virtual Container Host for Use with `dch-photon`](../vic_vsphere_admin/deploy_vch_dchphoton.md) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*. 

### Anonymous `dch-photon` Volumes <a id="vols"></a>

Each `dch-photon` container VM that you run creates an anonymous volume in the `default` volume store. By default, all of the images you pull into `dch-photon` go into this volume. The anonymous volume has a 2 GB limit. If you require more than 2 GB to store images and container state, you must explicitly specify a volume with a higher limit when you run `dch-photon`. 

The anonymous volumes that `dch-photon` creates are not deleted when you delete a `dch-photon` container VM.  This is by design, so that you can persist your image cache and container state beyond the lifespan of an individual `dch-photon` container VM. When you delete `dch-photon` container VMs, you must manually remove the anonymous volume from the volume store if you do not require them.

## Using `dch-photon` with vSphere Integrated Containers Registry <a id="registry"></a>

For `dch-photon` to be able to authenticate with vSphere Integrated Containers Registry, it needs to have the registry's CA certificate. 
The purpose of `dch-photon` is primarily to build images and push them to registries, so each `dch-photon` instance must be able to authenticate with the registry to which it pushes. Even if you use the same Docker client to pull and run the `dch-photon` image as you use to push built images back to the registry, the `dch-photon` container VM still needs to have the appropriate registry certificate so that it can successfully push images. 

You can provide the certificate to `dch-photon` in one of two ways:

-  Build a custom image that has the certificate embedded in it, as described in [Add the Registry Certificate to a Custom Image](photon_cert_custom.md). This method is preferable since you only need to perform the operation once.
-  Manually copy the certificate in to a `dch-photon` container running in a VCH by using `docker cp`, as described in [Manually Add the Registry Certificate to a `dch-photon` VM](photon_cert_manual.md).

When you have deployed `dch-photon` with the registry certificate, you can use it to build an image and push that image from `dch-photon` to vSphere Integrated Containers Registry. You can then pull the image from the registry into a VCH for deployment. For information about building, pushing, and pulling an image, see [Build, Push, and Pull an Image with `dch-photon`](test_photon.md).

## Using `dch-photon` with TLS Authentication and Other Registries <a id="other"></a>

For information about using `dch-photon` with TLS authentication and with other registries than vSphere Integrated Containers Registry, see [Advanced `dch-photon` Deployment](dchphoton_options.md). 

## Instantiating Docker Swarms with `dch-photon` <a id="swarm"></a>

You can use the `dch-photon` Docker Engine to instantiate a Docker swarm. For information about instantiating a Docker swarm, see [Automating Swarm Creation with vSphere Integrated Containers](https://blogs.vmware.com/cloudnative/2017/10/03/automating-swarm-creation-with-vic-1-2/).