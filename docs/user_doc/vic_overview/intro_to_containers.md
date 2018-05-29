# Introduction to Containers, Docker, and Registries

To understand vSphere Integrated Containers, you must first understand the main concepts of containers, Docker technnology, and container registries.

- [General Education Resources](#resources)
- [Container Images and Volumes](#images)
  - [Container Runtime](#runtime)
  - [Container Packaging](#packaging)

## General Education Resources <a id="resources"></a>

For an introduction to containers, Docker, and container registries before reading further, watch the videos on the [VMware Cloud-Native YouTube Channel](https://www.youtube.com/channel/UCdkGV51Nu0unDNT58bHt9bg):

<table>
				<tbody>
					<tr>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=EnJ7qX9fkcU' | noembed }}<!--EndFragment--></td>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=cCTLjAdIQho' | noembed }}<!--EndFragment--></td>
					</tr>
					<tr>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=VqLcWftIaQI' | noembed }}<!--EndFragment--></td>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=IhUvORodQAQ' | noembed }}<!--EndFragment--></td>
					</tr>
					<tr>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=L1ie8negCjc' | noembed }}<!--EndFragment--></td>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=PoiXuVnSxfE' | noembed }}<!--EndFragment--></td>
					</tr>
					<tr>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=76rX4s73MrM' | noembed }}<!--EndFragment--></td>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=jpC_p3bxXCI' | noembed }}<!--EndFragment--></td>
					</tr>
				</tbody>
			</table>


The following resources on docker.com and elsewhere are also useful:

- [Docker glossary](https://docs.docker.com/glossary/)
- [Get Started with Docker](https://docs.docker.com/get-started/)
- [Docker Sandbox](http://labs.play-with-docker.com/)
- [Play with Docker Classroom](http://training.play-with-docker.com/)

## Container Images and Volumes <a id="images"></a>

When understanding containers and how they relate to vSphere Integrated Containers, it is helpful to distinguish the *runtime* aspect of containers from the *packaging* aspect.

### Container Runtime <a id="runtime"></a>

At its most basic, a container is simply a sandbox in which a process can run. The sandbox isolates the process from other processes that are running on the same system. A container has a lifecycle which is typically tied to the lifecycle of the process that it is designed to run. If you start a container, it starts its main process and when that process ends, the container stops. The container might have access to some storage. It typically has an identity on a network.

Conceptually, a container represents many of the same capabilities as a VM. The main difference between the two is the abstraction layer:

* A software container is a sandbox within a guest OS and it is up to the guest to provide the container with its dependencies and to enforce isolation. Multiple containers share the guest kernel, networking, and storage. A container does not boot. It is simply a slice of an already-running OS. The OS running the container is called its *host*.

* In contrast, a VM is a sandbox within a hypervisor. It is the hypervisor that provides a VM with its dependencies, such as virtual disks and NICs. A VM has to boot an OS and its lifecycle is typically tied to that of the OS rather than to that of any one process. By design, a VM is strongly isolated from other VMs and its host.

One of the most interesting facets of containers is how they deal with state. Any data that a container writes is non-persistent by default and is lost when that container is deleted. State, however, can persist beyond the lifespan of a container by attaching a *volume* to it or by sending it over a network. Binary dependencies that the container needs, such as OS libraries or application binaries, are encapsulated in *images*. Images are immutable.


### Container Packaging <a id="packaging"></a>

One of the most significant benefits of containers is that they allow you to package up the entire environment that an application needs and run it anywhere. You can go to Docker Hub, select from hundreds of thousands of applications and run that application anywhere that you have installed Docker on a compatible OS. The packaging encapsulates the binary dependencies, environment variables, volumes, and even the network configuration. 

The format of this packaging is called an *image*. An image is a template from which many containers can instantiate. The Docker image format allows for images to be composed in a parent-child relationship, just like a disk snapshot. This image hierarchy allows containers to share common dependencies. For example, you might have a Debian 8 image that has a child image with Java installed. That Java image might have a child with Tomcat installed. The Debian 8 image might have other children, such as PHP, Python, and so on. 

The immutability of the image format means that you never modify an image, you always create a new one. The layered nature of the image format means that you can cache commonly-used layers so that you only need to download or upload the layers that you do not already have. It also means that if you want to patch a particular image, you create a new image and then rebuild all of its children. 

The main advantage of the image format is its portability. As long as you have a destination that is running a container engine, for example Docker, you can download and run an image on it. This portability is facilitated by a *registry*. A registry is a service that indexes and stores images. You can run your own private image registry that forms part of a development pipeline. You can *push* images to the registry from development, *pull* them into a test environment for verification, and then *pull* them into a production environment.

**Next topic**: [Introduction to vSphere Integrated Containers](intro_to_vic.md)