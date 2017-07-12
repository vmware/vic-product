# Building and Deploying Multi-Container Applications to a Virtual Container Host #

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

For this example, we're going to create two named volumes on different vSphere datastores. Database state is going to a persistent volume on a shared datastore that's backed up and encrypted. The Wordpress HTML state is going to a shared datastore that's less expensive.

We're going to create a private network for the database so that it's not exposed externally and expose the Wordpress container on an external network. 

The Wordpress application server and the database container don't necessarily have to be separate failure domains, but one of the advantages of VIC engine is that it makes it easy to deploy them that more secure way, so that's the approach we're taking here. 

The question of sizing is a simple matter of setting CPUs and memory on each container.

If we were to create a shell script to stand this up, it might look like this:

```
#!/bin/bash

DB_PASSWORD=wordpress
DB_USER=wordpress

# pull the images first
docker pull wordpress
docker pull mysql:5.7

# create a persistent volume for the database
docker volume create --opt Capacity=4G --opt VolumeStore=default db-data

# create a private network for the web container to talk to the database
docker network create --internal db-net

# start the database container - specify a subdirectory on the volume as the data dir
docker run -d --name db --net db-net -v db-data:/var/lib/mysql --cpus 1 -m 2g -e MYSQL_ROOT_PASSWORD=somewordpress -e MYSQL_DATABASE=$DB_PASSWORD -e MYSQL_USER=$DB_USER -e MYSQL_PASSWORD=wordpress mysql:5.7 --datadir=/var/lib/mysql/data

# wait until the database is up
while true; do
   docker exec db mysqladmin --user=$DB_USER --password=$DB_PASSWORD version > /dev/null 2>&1
   if [ $? -eq 0 ]; then
      break
   fi
   sleep 5
done

# start the web container - note it resolves the database container by name
docker create --name web --net ExternalNetwork -p 80 --cpus 2 -m 4g -e WORDPRESS_DB_HOST=db:3306 -e WORDPRESS_DB_USER=$DB_USER -e WORDPRESS_DB_PASSWORD=$DB_PASSWORD wordpress
docker network connect db-net web
docker start web

# output the IP addresses of the web container
docker inspect web | grep IPAddress
```
A second script to shut down the two containers and clean up everything might look like this:

```
#!/bin/bash

docker stop web db
docker rm web db
docker volume rm db-data html-data
docker network rm db-net
```

***Blocking on Container Readiness***

What's interesting about the script above is the use of `docker exec` as a means of blocking on the database being ready before starting the web container. It's worth noting that the MySQL [docker hub](https://hub.docker.com/_/mysql/) page states:

```
If there is no database initialized when the container starts, then a default database will be created. 
While this is the expected behavior, this means that it will not accept incoming connections until such initialization completes. 
This may cause issues when using automation tools, such as docker-compose, which start several containers simultaneously.
```
As such, if you don't have the blocking clause in the script, Wordpress may fail to start due to the database not being ready to accept connections and Wordpress timing out. That leaves you with three options:

1. If Wordpress wait time is configurable, reconfigure it. This is at least better than hardcoding a sleep into your script!
2. Build a simple blocking test into the orchestration, such as the one above.
3. Add a custom database connection test to the Wordpress image which runs before starting the main container process

The user of `docker exec` is the quickest and simplest mechanism you can use to run a binary in a running container and test its return code. A cleaner solution might be to add your own custom script to the database image that blocks until the database is ready and then call that using `docker exec`. This eliminates the need to call `docker exec` in a sleep loop. 

If you want to modify the Wordpress image, you will have to create a script that the container will evoke that runs the connection test before running the main process and deals correctly with signal handling. See [here](https://docs.docker.com/compose/startup-order/) for a discussion on ways to achieve this.

## Running Multi-Container Applications Using Docker Compose ##

Before we get into the topic of ***building*** applications for Docker Compose, let's example how we would run the equivalent of the above script using Docker Compose and vSphere Integrated Containers engine.

Docker Compose serializes a manifest in a YML file which the docker-compose binary turns into docker commands. The equivalent of the above script as a Docker Compose file would be the following:

```

```

*** A note on compatibility ***

First a note of caution. Given that VIC is designed to be an enterprise runtime and has unique isolation characteristics applied to the containers it deploys, a Docker Compose script downloaded from the web may not work without modification. This is partly also a question of functional completeness of VIC engine docker API support. There are some highly detailed technical sections in the documentation highlighting all of the capabilities VIC engine currently supports, but here is a high-level summary of some things to consider:

- VIC engine supports version 2 of the Compose File format.
- VIC engine has no native build support.
- VIC volumes are disks and when mounted, have a "lost+found" folder created by ext4. For some containers - databases in particular - you will need to configure them to use a subdirectory of the volume. See MySQL example above.
- VIC containers take time to boot and thus may exhibit timing related issues. Eg. You may need to set COMPOSE_HTTP_TIMEOUT to a higher value than the default.
- VIC containers have no notion of local read-write shared storage.

One of the main reasons this section takes you through all the considerations of putting a multi-container application into production with VIC prior to introducing Docker Compose is that you'll have likely have more success adapting Compose to VIC than trying to adapt VIC to Compose.



