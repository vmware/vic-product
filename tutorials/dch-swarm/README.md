# Automating docker swarm creation with vSphere Integrated Containers DCH

This is a simple shell script that deploys a Docker swarm manager node and then creates and joins a user-defined number of worker nodes to the swarm.

It was developed to showcase the flexiblility of the new [DCH](https://github.com/vmware/vic-product/tree/master/dinv) abstraction. The [DCH](https://github.com/vmware/vic-product/tree/master/dinv) functionality was introduced in [vSphere Integrated Containers](https://www.vmware.com/products/vsphere/integrated-containers.html) (VIC) 1.2 to simplify the provisioning of the Docker hosts by packaging the Docker host as a container that can be instantiated on VIC.

For more information, please see this [article](https://blogs.vmware.com/cloudnative/2017/10/03/automating-swarm-creation-with-vic-1-2/).
