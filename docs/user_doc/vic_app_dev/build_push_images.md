# Building and Pushing Images with the `dch-photon` Docker Engine 

vSphere Integrated Containers Engine is an enterprise container runtime that you use as a deployment endpoint. As such, it does not have native `docker build` or `docker push` capabilities. The job of building and pushing container images is typically part of a CI pipeline which does this by using standard Docker Engine instances. 

- You use standard Docker Engine to build, tag, and push a container image to a registry.
- You pull the image from the registry to a vSphere Integrated Containers virtual container host (VCH) to deploy it.

vSphere Integrated Containers Engine can deploy Docker Engine instances for you, in the form of a container image repository named `dch-photon`. This image is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. The `dch-photon` image allows you to deploy a container VM that runs a Docker Engine instance hosted in Photon OS. You can deploy any number of these Docker Engine instances to perform `docker build` and `docker push` operations as part of your CI infrastructure. 

- [Requirements for Using `dch-photon`](#requirements)
- [Using `dch-photon` with vSphere Integrated Containers Registry](#registry)
- [Using `dch-photon` with Other Registries](#other)

## Requirements for Using `dch-photon` <a href="requirements"></a>

To use `dch-photon`, your environment must satisfy the following conditions: 

- Configure your local Docker client to use the vSphere Integrated Containers Registry certificate. For information about how to obtain the registry certificate and pass it to the Docker client, see [Using vSphere Integrated Containers Registry](configure_docker_client.md#registry).
- You have access to a VCH that the vSphere administrator configured so that it can connect to the registry to pull the `dch-photon` image. The VCH must also have a volume store named `default`. For information about how deploy a VCH for use with `dch-photon`, see the [Deploy a Virtual Container Host for Use with `dch-photon`](../vic_vsphere_admin/deploy_vch_dchphoton.md) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*. 

## Using `dch-photon` with vSphere Integrated Containers Registry <a href="registry"></a>

For `dch-photon` to be able to authenticate with vSphere Integrated Containers Registry, it needs to have the registry's CA certificate. You can provide the certificate to `dch-photon` in one of two ways:

-  Build a custom image that has the certificate embedded in it, as described in [Adding the Registry Certificate to a Custom Image](photon_cert_custom.md). This method is preferable since you only need to perform the operation once.
-  Manually copy the certificate in to a `dch-photon` container running in a VCH by using `docker cp`, as described in [Manually Adding the Registry Certificate to a `dch-photon` VM](photon_cert_manual.md).

When you have deployed `dch-photon` with the registry certificate, you can use it to build an image and push that image from `dch-photon` to vSphere Integrated Containers Registry. You can then pull the image from the registry into a VCH for deployment. For information about building, pushing, and pulling an image, see [Build, Push, and Pull an Image with `dch-photon`](test_photon.md).

## Using `dch-photon` with Other Registries <a href="other"></a>

For information about using `dch-photon` with other registries than vSphere Integrated Containers Registry, see [Advanced `dch-photon` Deployment](dchphoton_options.md). 
