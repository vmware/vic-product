# Deploy a Single Container to a Virtual Container Host #

This section assumes that you already have a Virtual Container Host installed and that you are accessing it using TLS authentication.

For simplicity, pre-built Docker images are demonstrated to illustrate principles of operation. It is assumed that in reality you will have your own Docker images built.

This section will illustrate a number of useful capabilities such as pre-poluating data volumes, creating custom images and running daemon processes.

**Deploying a Database - Postgres 9.6**

All databases will have common requirements. A database should almost always be strongly isolated and long-running, so is a perfect candidate for a container VM. Steps to consider include:

1. Choose a volume store for your database state
2. Choose a size for your persistent volume
3. Choose a network for your container. Does it need to be exposed externally or privately to other containers?
4. How many CPUs and how much memory do you want for your database?

Note that the [Dockerfile](https://github.com/docker-library/postgres/blob/972294a377463156c8d61297320c872fc7d370a9/9.6/Dockerfile) uses VOLUME and EXPOSE to illustrate that it needs to store persistent state and that you should be able to reach it on a particular port. As discussed [here](putting_apps_into_production.md), anonymous volumes and random port mappings are fine for a sandbox, but not for production. 

In this example, we create a 10GB volume disk on a backed up shared datastore. We'll use a private network to access the database, assuming that another container will need to access it privately. We use environment variables to set the data directory and password. We give the container a name so that it can be resolved using that name on the private network. Finally, we choose 2 vCPUs and 4GB of RAM.

```
docker network create datanet
docker volume create --opt Capacity=10G --opt VolumeStore=shared-backedup pgdata
docker run --name db -d -v pgdata:/var/lib/postgresql/data -e PGDATA=/var/lib/postgresql/data/data -e POSTGRES_PASSWORD=y7u8i9o0p --cpus 2 -m 4g --net datanet postgres:9.6
```

Once the container has started, you can use `docker ps` to make sure it's running. You can use `docker logs db` to see the logs. You can use `docker exec -it db /bin/bash` (only available in VIC 1.2+) to get a shell into the container.

Now let's check that it's visible on the private network and it's running correctly. We can do this using a VIC container running on the same private network:

```
docker run --rm -it --net datanet postgres:9.6 /bin/bash
   $ ping db
     PING db (172.18.0.2): 56 data bytes
     64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.856 ms
     ...
   $ pg_isready -h db
     db:5432 - accepting connections
```
If we stop and delete the container, the data volume will persist. It will even persist beyond the lifespan of the VCH unless `vic-machine delete --force` is used.

**Deploying an Application Server - Tomcat 9 with JRE 8**

Looking at the [Dockerfile](https://github.com/docker-library/tomcat/blob/1cb69781deeac97b2bb138054de3b2f35e9b49a0/9.0/jre8/Dockerfile) here, there are no anonymous volumes specified. However, we need to consider how to get our application deployed and we may want to set some JVM configuration.

Let's start by deploying Tomcat on an external container network to make sure it works

```
docker run --name web -d -p 8080 -e JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom" --net ExternalNetwork tomcat:9
docker logs web
docker inspect web | grep IPAddress
curl <external-ip>:8080
```
Hopefully an index.html showing Tomcat server running is shown. Of course you can also test this using a browser. Note that you can pass JRE options in as an environment variable. In this case, we're passing in an option to get Tomcat to start faster by using a non-blocking entropy source (see https://wiki.apache.org/tomcat/HowTo/FasterStartUp).

Next step is to consider how to get a webapp onto the application server. There are static and dynamic approaches to this problem. 

***Pre-populate a Volume***

You can use a container to pre-populate a volume with a web application that you then bind when you run the application server. This is a late-binding dynamic approach that has the advantage that the container image remains general-purpose. The downside is that it requires an extra step to populate the volume.

```
docker volume create webapp
docker run --rm -v webapp:/data -w /data tomcat:9 curl -O https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war
docker run --name web -d -p 8080 -e JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom" -v webapp:/usr/local/tomcat/webapps --net ExternalNetwork tomcat:9
curl <external-ip>:8080/sample
```
The volume is a disk of default size, in this case 1GB. The command to populate the volume mounts it at /data and then tells the container to use /data as the working directory. It then uses the fact that the Tomcat container has `curl` installed to download a sample web app as a WAR file to the volume. When the volume is mounted to /usr/local/tomcat/webapps, it replaces any existing webapps such as the welcome page and Tomcat runs just the sample app.

If you don't want the volume to completely replace the existing /webapps directory, you can modify the above example to extract the WAR file to the volume and then mount the volume as a subdirectory of webapps.

```
docker volume create webapp
docker run --rm -v webapp:/data -w /data tomcat:9 /bin/bash -c "curl -O https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war; unzip sample.war; rm sample.war"
docker run --name web -d -p 8080 -e JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom" -v webapp:/usr/local/tomcat/webapps/sample --net ExternalNetwork tomcat:9
curl <external-ip>:8080/sample
```
Note that running multiple commands on a container can be done using `/bin/bash -c`. There's a discussion below as to why this isn't necessarily ideal for a running service, but for chaining simple commands together, it works fine. Now, not only is your sample app available, but any other app baked into the image in /usr/local/tomcat/webapps is also available.

***Build a custom image***

Building a custom image allows you to copy the sample webapp into the container image filesystem and make some other improvements and upgrades while you're there. This then creates a single purpose container that runs the webapp(s) baked into it.

Note that VIC engine does not have a native docker build capability. Containers should be built using docker engine and VIC engine relies on the portability of the Docker image format to run them. In order to do this, the built image needs to be pushed to a registry that the VCH can access. This is one reason why such a registry is built into the vSphere Integrated Containers product.

Dockerfile:
```
FROM tomcat:9

ENV JAVA_OPTS "-Djava.security.egd=file:/dev/./urandom"
COPY sample.war /usr/local/bin/webapps
```
In a VM running standard docker engine:
```
docker build -t <registry-address>/<image name> .
docker login <registry-address>
docker push <registry-address>/<image name>
```
From a docker client attached to a VCH
```
docker run --name web -d -p 8080 --net ExternalNetwork <registry-address>/<image name>
```
Note that the use of the /dev/urandom above is not considered particularly secure as it doesn't address the underlying problem of lack of entropy. One of the advantages of building a new image is that it can be customized, so for example, you can install the [haveged](https://linux.die.net/man/8/haveged) package to solve your entropy problem.

However, one of the interesting challenges of containers is that they're designed to only run one process and they don't have a conventional init system. So installing haveged in a Dockerfile doesn't mean that it will actually run when deployed.

Let's examime some solutions to this problem

***Running Daemon Processes in a VIC container***

Although a VIC container is a VM, it is a very opinionated VM in that it has the same constraints as a container. It doesn't have a conventional init system and its lifecycle is coupled to a single main process. There are a few ways of running daemon processes in a container - many of which are far from ideal.

For example, simply chaining commands in a Dockerfile CMD instruction techically works, but it compromises the signal handling and exit codes of the container. As a result, `docker stop` will almost certainly not work as intended. What would that look like in our Tomcat example?

```
FROM tomcat:9

RUN apt-get update;apt-get install -y haveged
COPY sample.war /usr/local/bin/webapps
CMD /usr/sbin/haveged && catalina.sh run
```
So this is not a recommended approach. Try running `docker stop` and it will timeout and eventually kill the container. This is not a problem exclusive to VIC engine, this is a general problem with container images.

A much simpler approach is to run haveged using `docker exec` once the container is started:

```
docker run --name web -d -p 8080 -v webapp:/usr/local/tomcat/webapps --net ExternalNetwork <registry-address>/<image name>
docker exec -d web /usr/sbin/haveged
```
Docker exec with the `-d` option runs a process as a daemon in the container. While this is arguably the neatest solution to the problem, it does require a subsequent call to the container after it's started. While it's realtively simple to script this, it doesn't work well in a scenario such as a Compose file.

So a third approach is to create a script that the container starts when it initializes that uses a trap handler to manage signals.

rc.local
```
#!/bin/bash

cleanup() 
{
   kill $(pidof /docker-java-home/jre/bin/java)
}

trap cleanup EXIT

/usr/sbin/haveget
catalina.sh run
```

Dockerfile
```
FROM tomcat:9

RUN apt-get update;apt-get install -y haveged
COPY sample.war /usr/local/bin/webapps
CMD [ "/etc/rc.local" ]
COPY rc.local /etc/
```

**Deploying a Development Environment**

You can use VIC to run a development environment that can be used either interactively or as a means of running builds or test suites.

Let's look at some simple examples. Regardless of the approach, we'll need code mounted into the development environment. The simplest way to achieve this is using a volume. Let's download the VIC repository onto a volume.

```
docker volume create vic-build
docker run --rm -v vic-build:/build -w /build golang:1.8 git clone https://github.com/vmware/vic.git
```
***Interactive***

The source code tree lives on the persistent volume and can be re-used across invocations of the development environment. The command below will take you straight into a golang development environment shell.

```
docker run --rm -it -v vic-build:/go/src/github.com/vmware/ -w /go/src/github.com/vmware/vic golang:1.8 
```
***Running a Build***

Let's build VIC using the volume created above. That's a simple matter of appropriately sizing the container VM and running `make`.

```
docker run --rm -m 4g -v vic-build:/go/src/github.com/vmware/ -w /go/src/github.com/vmware/vic golang:1.8 make all
```
The output of the build also lives on the volume. You need to ensure that the volume is big enough. VIC engine 1.2 will support NFS volume mounts which could be a great alternative for the build source and output.




