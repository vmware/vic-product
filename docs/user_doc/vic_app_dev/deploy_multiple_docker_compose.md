# Building and Deploying Mutli-Container Applications to a Virtual Container Host #

Having examined some of the considerations around deploying single containers to a Virtual Container Host, this section examples how to deploy applications that are comprised of multiple containers.

There are two approaches you can take to this. You can simply create scripts that create networks, volumes and manages the application lifecycle. You can even build and run these scripts as containers! 

The second approach is to use a manifest-based orchestrator such as Docker Compose. VIC 1.1 has some basic support for Docker Compose, but it is not functionally complete. Docker Compose is a prioritary orchestrator that drives the Docker API and ties other pieces of the Docker ecosystem together including Build and Swarm. Given that VIC engine doesn't currently support either Build or Swarm, Compose compatibility is necessarily limited. However, Compose can still be a useful tool, provided those limitations are understood.

## Scripting Multi-Container Applications ##

Let's start by looking at how you would script Wordpress running in one container and a MySQL database in another. We can then use some of the considerations and topics discussed and apply that to the Compose example later.

As with the single container examples, we need to consider:
1. What persistent state needs to be stored, where should it go and how should it be?
2. How should the containers communicate with each other?
3. Does each container need to be strongly isolated?
4. How should each container be sized?

For this example, we're going to create a named volume on a vSphere datastore that we've chosen because it's backed up. We're going to create a private network for the database so that it's not exposed externally and expose the Wordpress container on an external network. The Wordpress application server and the database container don't necessarily have to be separate failure domains, but one of the advantages of VIC engine is that it makes it easy to deploy them that more secure way, so that's the approach we're taking here. The question of sizing is a simple matter of setting CPUs and memory on each container.

```
docker pull wordpress
docker pull mysql:5.7
docker volume create --opt Capacity=4G db-data
docker network create --internal db-net

