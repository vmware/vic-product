# vSphere Integrated Containers

vSphere Integrated Containers (VIC) is comprised of three main components -
the [vSphere Integrated Containers Engine](https://github.com/vmware/vic), [Harbor](https://github.com/vmware/harbor), and [Admiral](https://github.com/vmware/admiral) all of which are available as open source on github.

The [VIC Engine](https://github.com/vmware/vic) is a container runtime for vSphere, allowing developers familiar with Docker to develop in containers and deploy them alongside traditional VM-based workloads on vSphere clusters. These workloads can be managed through the vSphere UI in a way familiar to existing vSphere admins.

[Harbor](https://github.com/vmware/harbor), the enterprise container registry, is an enterprise-class registry server that stores and distributes container images. Harbor extends the open source project Docker Distribution by adding the functionalities usually required by an enterprise, such as security, identity and management.

[Admiral](https://github.com/vmware/admiral), the container management portal, provides a UI for developers and app teams to provision and manage containers, including retrieving stats and info about container instances. Cloud administrators will be able to manage container hosts and apply governance to its usage, including capacity quotas and approval workflows. When integrated with vRealize Automation, more advanced capabilities become available, such as deployment blueprints and enterprise-grade Containers-as-a-Service.

With these three capabilities, VIC enables VMware customers to deliver a production ready container solution to their developers and app teams. By leveraging their existing SDDC, customers can now run container-based applications alongside existing virtual machine based workloads in production without having to build out a separate, specialized container infrastructure stack. As an added benefit for customers and partners, VIC is modular. So if your organization already has a container registry in production, you can use that registry with the other components of vSphere Integrated Containers.

## Installing
Please refer to the [documentation](https://github.com/vmware/vic-product/tree/master/docs/setup/beta) for installing and testing VIC

***Note that each of the components have varying degrees of functional completeness and are not yet GA quality code. As such, there are various caveats and known issues around usage, the majority of which will have been documented***

## Contributing to vSphere Integrated Containers

Contributors and users are encouraged to collaborate using the following resources:


For cross-component issues, please use the [vic-product Github issue tracker](https://github.com/vmware/vic-product/issues)



For issues relating to individual components, please use the component specific Github issue tracker:

[VIC Engine](https://github.com/vmware/vic/issues)

[Harbor](https://github.com/vmware/harbor/issues)

[Admiral](https://github.com/vmware/admiral/issues)


## License
The vic-product components are licensed under Apache 2 with additional licenses denoted within each open source repository ([VIC](https://github.com/vmware/vic/blob/master/LICENSE), [Admiral](https://github.com/vmware/admiral/blob/master/LICENSE), [Harbor](https://github.com/vmware/harbor/blob/master/LICENSE))
