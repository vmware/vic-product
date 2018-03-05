# Building and Deploying Multi-Container Applications to a Virtual Container Host #

Having examined some of the considerations around deploying single containers to a Virtual Container Host (VCH), this section examples how to deploy applications that are comprised of multiple containers.

There are two approaches you can take to this. The most instinctive approach would be to create scripts that manage the lifecycle of volumes, networks and containers.

The second approach is to use a manifest-based orchestrator such as Docker Compose. Docker Compose is a proprietary orchestrator that drives the Docker API and ties other pieces of the Docker ecosystem together including Build and Swarm. Given that VIC engine doesn't currently support either Build or Swarm, Compose compatibility is necessarily limited. However, Compose can still be a useful tool, provided those limitations are understood.

## Scripting Multi-Container Applications ##

Let's start by looking at how you would script Wordpress running in one container and a MySQL database in another. We can then use some of the considerations and topics discussed and apply that to the Compose example later.

As with the single container examples, we need to consider:
1. What persistent state needs to be stored and where should it go?
2. How should the containers communicate with each other?
3. Does each container need to be strongly isolated?
4. How should each container be sized?

For this example, we're going to create two named volumes on different vSphere datastores. Database state is going to a persistent volume on a shared datastore that's backed up and encrypted. The Wordpress HTML state is going to a shared datastore that's less expensive.

We're going to create a private network for the database and expose the Wordpress container on a second network that exposes a port on the VCH endpoint.

The Wordpress application server and the database container don't necessarily have to be separate failure domains, but one of the advantages of VIC engine is that it makes it easy to deploy them that more secure way, so that's the approach we're taking here. 

The question of sizing is a simple matter of setting virtual CPUs and memory on each container.

If we were to create a shell script to stand this up, it might look like this:

```
#!/bin/bash

DB_PASSWORD=wordpress
DB_USER=wordpress

WEB_CTR_NAME=web
DB_CTR_NAME=db

# pull the images first
docker pull wordpress
docker pull mysql:5.7

# create a persistent volume for the database
docker volume create --opt Capacity=4G --opt VolumeStore=backed-up-encrypted db-data
docker volume create --opt Capacity=2G --opt VolumeStore=default html-data

# create a private network for the web container to talk to the database. This will fail if the network already exists.
docker network create --internal db-net
docker network create web-net

# start the database container - specify a subdirectory on the volume as the data dir
docker run -d --name $DB_CTR_NAME --net db-net -v db-data:/var/lib/mysql --cpus 1 -m 2g -e MYSQL_ROOT_PASSWORD=somewordpress -e MYSQL_DATABASE=$DB_PASSWORD -e MYSQL_USER=$DB_USER -e MYSQL_PASSWORD=wordpress mysql:5.7

# start the web container - note it resolves the database container by name over db-net
docker create --name $WEB_CTR_NAME --net web-net -p 8080:80 -v html-data:/var/www/html --cpus 2 -m 4g -e WORDPRESS_DB_HOST=$DB_CTR_NAME:3306 -e WORDPRESS_DB_USER=$DB_USER -e WORDPRESS_DB_PASSWORD=$DB_PASSWORD wordpress

docker network connect db-net $WEB_CTR_NAME

docker start $WEB_CTR_NAME

# check that the containers are up and look at the IP address and port of the web container
docker ps | grep "$WEB_CTR_NAME\|$DB_CTR_NAME"
```
A second script to shut down the two containers and clean up everything might look like this:

```
#!/bin/bash

docker stop web db
docker rm web db

# uncomment to delete volume state
# docker volume rm db-data html-data

# uncomment to delete networks
# docker network rm db-net web-net
```

***Blocking on Container Readiness***

In the above example, the Wordpress container waits for about 10 seconds for the database to come up and be ready. What if it needs to wait longer than that? This is one of the ways `docker exec` can be useful. For example:

```
# wait until the database is up
while true; do
   docker exec -it db mysqladmin --user=$DB_USER --password=$DB_PASSWORD version > /dev/null 2>&1
   if [ $? -eq 0 ]; then
      break
   fi
   sleep 5
done
```

It's worth noting that the MySQL [docker hub](https://hub.docker.com/_/mysql/) page states:

```
If there is no database initialized when the container starts, then a default database will be created. 
While this is the expected behavior, this means that it will not accept incoming connections until such initialization completes. 
This may cause issues when using automation tools, such as docker-compose, which start several containers simultaneously.
```

The user of `docker exec` is the quickest and simplest mechanism you can use to execute a binary in a running container and test its return code. A cleaner solution might be to add your own custom script to the database image that blocks until the database is ready and then call that using `docker exec`. This eliminates the need to call `docker exec` in a sleep loop. 

If you want to modify the Wordpress image to add a database connection test, you would have to create a script that the container will evoke that runs the test before running the main process and deals correctly with signal handling. See [here](https://docs.docker.com/compose/startup-order/) for a discussion on ways to achieve this.

## Running Multi-Container Applications Using Docker Compose ##

Before we get into the topic of ***building*** applications for Docker Compose, let's look at an example of how we would run the equivalent of the above script using Docker Compose and vSphere Integrated Containers engine.

Docker Compose serializes a manifest in a YML file which the `docker-compose` binary turns into docker commands. The equivalent of the above script as a Compose file would be the following:

```
version: '2'

services:
   db:
     image: mysql:5.7
     command: --datadir=/var/lib/mysql/data
     volumes:
       - db-data:/var/lib/mysql
     networks:
       - db-net
     environment:
       MYSQL_ROOT_PASSWORD: somewordpress
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: wordpress

   wordpress:
     depends_on:
       - db
     image: wordpress:latest
     ports:
       - "8080:80"
     volumes:
       - html-data:/var/www/html
     networks:
       - web-net
       - db-net
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: wordpress
       WORDPRESS_DB_PASSWORD: wordpress

volumes:
    db-data:
       driver: "vsphere"
       driver_opts:
          Capacity: "4G"
          VolumeStore: "backed-up-encrypted"
    html-data:
       driver: "vsphere"
       driver_opts:
          Capacity: "2G"
          VolumeStore: "default"

networks:
    web-net:
    db-net:
       internal: true
```
Note that there is no way to run `exec` commands explicitly in a compose file, so any waits for dependent services to come up need to be built into the containers themselves.

## How to Manage the Application Lifecycle with docker-compose and VIC engine ##

Assuming you've downloaded an appropriate version of the docker-compose binary, you need to point docker-compose at a VCH endpoint. This is done either by setting `DOCKER_HOST=<endpoint-ip>:<port>` or using `docker-compose -H <endpoint-ip>:<port>`. 

***Dependencies between the compose file and vic-machine configuration***

Given that the VCH lifecycle is handled by a vSphere administrator, there may be some named resources in the VCH that need to be referenced in the Compose file. For example, in the Compose file above are the names of two volume stores. There may other assumptions, such as the name of a container network for example. As a user, it's important to know how to get this information from your VCH so that you can configure your Compose file appropriately.

To view a list of networks that have been pre-configured by the vSphere admin, use `docker network ls` and look for ones marked `external`. 

To view a list of volume stores that have been pre-configured by the vSphere admin, use `docker info | grep VolumeStores`.

***TLS Authentication***

Assuming you're using TLS authentication to the Docker endpoint, that is either done using environment variables or command-line options. 

With environment variables, it's assumed that you've already set `DOCKER_TLS_VERIFY=1` and `DOCKER_CERT_PATH=<path to client certs>`. This is required in order to use the docker client. For `docker-compose` you have to additionally set `COMPOSE_TLS_VERSION=TLSv1_2`. You can then run `docker-compose up -d` to start the application (assuming you've also set `DOCKER_HOST` to point to the VCH endpoint).

Using command-line arguments with docker client is a little more clumsy as each key has to be specified independently and the same is true of `docker-compose`. Regardless, the only way to specify the TLS version is through the environment variable above `COMPOSE_TLS_VERSION=TLSv1_2`. You can then run `docker-compose -H <endpoint-ip>:2376 --tlsverify --tlscacert="<local-ca-path>/ca.pem" --tlscert="<local-ca-path>/cert.pem" --tlskey="<local-ca-path>/key.pem" compose up -d`

***Lifecycle Commands***

The docker-compose binary is well documented and it is outside of the scope of this document to go into detail on that. However, given the example given above, the following lifecycle commands work:

```
docker-compose pull                    # pull the required images
docker-compose up -d                   # start the application in the background
docker-compose logs                    # see the logs of the containers started
docker-compose images                  # list the images in use
docker-compose stop                    # cleanly stop the running containers, leave container state
docker-compose kill                    # force kill of the container processes
docker-compose start                   # restart the application
docker-compose down                    # stop the application and remove the resources, leaving persistent volumes and images
docker-compose down --volumes --rmi    # stop the application and remove all resources including volumes and images
```

## Building Multi-Container Applications Using Docker Compose ##

Given that VIC engine does not have a native build capability, it does not interpret the `build` keyword in a compose file and `docker-compose build` will not work when `DOCKER_HOST` points to a VIC endpoint. VIC engine relies upon the portability of the docker image format and it is expected that a regular docker engine will be used in a CI pipeline to build container images for test and deployment.

There are two ways to work around this. You can create separate Compose files for build and run, or you can use the same Compose file but just make sure to add a couple of arguments. We will explore both options here using another example of a Compose file that includes build instructions. In this case, the sample voting application found [here](https://github.com/dockersamples/example-voting-app/blob/master/docker-compose-simple.yml).

Let's start by cloning the repository: `git clone git@github.com:dockersamples/example-voting-app.git` and we'll start by looking at `docker-compose-simple.yml`. 

***Using separate Compose files***

You can strip a Compose file down to an absolute minimum if you want to use it just for building and pushing images. If you want to run the application on a VIC endpoint, you'll need to also push the built images to a docker registry visible to your VCH, so that they can be deployed. In order to do that, we need to add `image` directives to the Compose file.

```
$ more docker-compose-simple-build.yml 
version: "2"

services:
  vote:
    build: ./vote
    image: <registry-address>/<project>/vote:0.1

  worker:
    build: ./worker
    image: <registry-address>/<project>/worker:0.1

  result:
    build: ./result
    image: <registry-address>/<project>/result:0.1

$ sudo docker-compose -f docker-compose-simple-build.yml build 
$ sudo docker login <registry>
$ sudo docker-compose -f docker-compose-simple-build.yml push
```

Now that the application is built and pushed, you need to create a second Compose file for deployment that reflects the deployment considerations discussed earlier in terms of isolation, peristent volume state, networking etc. The Compose file provided in the repo is simply an example and you would typically expect to have to change it to suit your needs. Let's do that, but keep it as simple as possible to begin with. 

Modifications from the original file are highlighted as comments

```
version: "2"      # VIC engine supports Compose file version 2

services:
  vote:
    image: <registry-address>/<project>/vote:0.1    # Fully-qualified image name
    command: python app.py
    ports:                          # Local ./vote volume mount removed - use the app.py built-in
      - "5000:80"

  redis:
    image: redis:alpine
    ports: ["6379"]

  worker:
    image: <registry-address>/<project>/worker:0.1    # Fully-qualified image name

  db:
    image: postgres:9.4

  result:
    image: <registry-address>/<project>/result:0.1    # Fully-qualified image name
    command: nodemon --debug server.js
    ports:                          # Local ./results volume mount removed - use the server.js built-in
      - "5001:80"
      - "5858:5858"
```

Let's review the changes that were made to this Compose file. 

- Fully qualified image name

In most real-world scenarios, container images will be pushed to a registry before they're deployed into production. That means that the registry and a project will be part of the image name. The only way it will run with just the container name is if it has been built locally.

- Removed local volume mappings

Local volume mounts are useful for development and testing as they allow source trees and data to be easily mapped into a container. In production however, making a container host stateful for the purpose of seeding the container with configuration or application data is only feasible if the container is guaranteed to be deployed to the stateful host. In general, best practice is to keep a container host as stateless as possible. 

VIC engine cannot map volumes from a local filesystem into a container because VIC engine containers are strongly isolated and don't share a common filesystem. Despite this, it is still possible in VIC to add state to a container by pre-populating a volume with data and mounting it (TBD: link to "Pre-populate a Volume").

***Combining into a single Compose file***

If separate Compose files feels clunky, it's quite possible to build, push and run from the same Compose file. All we need to do is to merge them together and then make sure we tell docker-compose what we want. Here's an example of a merged file:

```
version: "2"

services:
  vote:
    build: ./vote
    image: <registry-address>/<project>/vote:0.1
    command: python app.py
    ports:
      - "5000:80"

  redis:
    image: redis:alpine
    ports: ["6379"]

  worker:
    build: ./worker
    image: <registry-address>/<project>/worker:0.1

  db:
    image: postgres:9.4

  result:
    build: ./result
    image: <registry-address>/<project>/result:0.1
    command: nodemon --debug server.js
    ports:
      - "5001:80"
      - "5858:5858"
```
Build and push work in just the same way as the previous example. The rest of the directives are ignored. 

In order to deploy this to a VIC endpoint however, you need to first explicitly pull the images. Otherwise docker-compose will try to build them, even if you attempt to run with `--no-build`. Then you run the Compose file with `--no-build` to tell docker-compose to ignore the build directives. 

```
$ sudo docker-compose -f docker-compose-simple-vic.yml build
$ sudo docker-compose -f docker-compose-simple-vic.yml push
$ docker-compose -f docker-compose-simple-vic.yml pull
$ docker-compose -f docker-compose-simple-vic.yml up --no-build -d
```

In the example above, the use of `sudo` creates a child shell that runs a local docker engine and bypasses the environment variables configured to make docker-compose talk to a VIC endpoint. In this way, it's possible to do a build, push, pull and run from the same shell using the same client.

## A Summary on Compatibility ##

Given that VIC is designed to be an enterprise runtime and has unique isolation characteristics applied to the containers it deploys, a Docker Compose script downloaded from the web may not work without modification. 

This is partly a question of functional completeness of VIC engine docker API support and partly a question of its inherent design. There are some highly detailed technical sections in the documentation highlighting all of the capabilities VIC engine currently supports, but here is a high-level summary of topics discussed in more detail above:

- VIC engine supports version 2 of the Compose File format.
- VIC engine has no native build support.
- VIC containers take time to boot and thus may exhibit timing related issues. Eg. You may need to set `COMPOSE_HTTP_TIMEOUT` to a higher value than the default.
- VIC containers have no notion of local read-write shared storage.

One of the main reasons this section takes you through all the considerations of putting a multi-container application into production with the Docker client prior to introducing Docker Compose is to help you understand how to configure Compose to work with the capabilities of VIC. Trying to work the opposite way around, by trying to configure VIC to work with capabilities of Compose may be trickier for the reasons stated.


