```
Mirrored from: https://blogs.vmware.com/vsphere/2017/02/deploying-wordpress-vsphere-integrated-containers.html
Author: Cheng Wang
Posted: February 13, 2017
```

# Deploying WordPress in vSphere Integrated Containers

WordPress is a popular, open-source tool for the agile deployment of a blogging system. In this article, we offer a step-by-step guide for deploying WordPress in vSphere Integrated Containers. This involves creating two containers: one running a mysql database and the other running the wordpress web server. We provide three options:

1. Deploy using docker commands in vSphere Integrated Container
2. Deploy using docker-compose in vSphere Integrated Containers
3. Deploy using Admiral and vSphere Integrated Containers

## Deploy using docker commands in vSphere Integrated Containers

First, we need to install the virtual container host (VCH) with a volume store, which is used to persist the db data. In the following example, I create a VCH with a volume store test with the tag default under datastore1:

```
vic-machine-linux create --name=vch-test --volume-store=datastore1/test:default --target=root:pwd@192.168.60.162 --no-tlsverify --thumbprint=… --no-tls
```

Second, we deploy a container which runs the mysql database:

```
docker -H VCH_IP:VCH_PORT run -d -e MYSQL_ROOT_PASSWORD=wordpress -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=wordpress -v mysql_data:/var/lib/mysql --name=mysql mysql:5.6
```

Replace `VCH_IP` and `VCH_PORT` with the actual IP and port used by the VCH, which can be found from the command line output of the above _vic-machine-linux create_. Here `-v mysql_data:/var/lib/myql` mounts the volume `mysql_data` to the directory `/var/lib/mysql` within the mysql container. Since there is no such volume `mysql_data` on the VCH, the VIC engine creates a volume with the same name in the default volume store test.

Third, we deploy the wordpress server container:

```
docker -H VCH_IP:VCH_PORT run -d -p 8080:80 -e WORDPRESS_DB_HOST=mysql:3306 -e WORDPRESS_DB_PASSWORD=wordpress --name wordpress wordpress:latest
```

Now if you run `docker –H VCH_IP:VCH_PORT` ps, you should see both containers running. Open a browser and access `http://VCH_IP:8080`. You should be able to see the famous WordPress start page below:

![Screenshot of WordPress start page](https://blogs.vmware.com/vsphere/files/2017/02/wordpress_start.png)

In addition, if you connect to your ESXi host or vCenter which hosts the VCH and the volume store, you should be able to find the data volume `mysql_data` under `datastore1/test`:

![Screenshot of Datastore browser](https://blogs.vmware.com/vsphere/files/2017/02/mysql_data.png)


## Deploy using docker-compose in vSphere Integrated Containers

Using _docker-compose_ on vSphere Integrated Containers is as easy as on vanilla docker containers. First, you need to create the _docker-compose.yml_ file as follows:

```
version: '2'

services:
   db:
     image: mysql:5.6
     environment:
       MYSQL_ROOT_PASSWORD: wordpress
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: wordpress

   wordpress:
     depends_on:
       - db
     links:
       - db
     image: wordpress:latest
     ports:
       - "8080:80"
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_PASSWORD: wordpress
       WORDPRESS_DB_NAME: wordpress
```

Then simply run

```
docker-compose –H VCH_IP:VCH_PORT up –d
```

Open a browser and access `http://VCH_IP:8080`. You should be able to see the WordPress start page. Note that as of VIC engine 0.8, the volumes option is not yet support for _docker-compose_, which is why we only store the db data in the db container instead of persistent storage. A future release will include this feature.


## Deploy using Admiral and vSphere Integrated Containers

Admiral is the management portal through which you can easily deploy containers using the Admiral UI or a template (similar to the _docker-compose.yml_ file used by _docker-compose_). In this example, we will focus on deploying WordPress via the Admiral UI.

First, we need to deploy a container which runs the Admiral service:

```
docker –H VCH_IP:VCH_PORT run -d -p 8282:8282 --name admiral vmware/admiral
```

Go to the web page `http://VCH_IP:8282` and add the VCH host to Admiral based on [these instructions](https://github.com/vmware/vic-product/blob/master/docs/setup/beta/install-configure-admiral.md).

Second, create the mysql container by choosing _Resources -> Containers -> Create Container_, and input the parameters of the docker command you used previously when deploying WordPress on VIC. Don’t forget to set the _ENVIRONMENT_ variables. Click on _Provision_ to launch the container.

![Screenshot of Admiral Provision a Container](https://blogs.vmware.com/vsphere/files/2017/02/provision_container.png)

Now you should be able to see both the admiral container and the mysql container in the Admiral UI. Note down the actual container name of the mysql container (Admiral adds suffix to your specified name as the actual container name).

![Screenshot of Admiral deployed containers](https://blogs.vmware.com/vsphere/files/2017/02/admiral_mysql.png)

Third, deploy the wordpress container following the same flow as in the second step. Note that the environment variable `WORDPRESS_DB_HOST` should be set to `mysql_container_name:3306`.

Finally, open a browser and access `http://VCH_IP:8080`. You should be able to see the WordPress start page again.

Alternatively, you can also use the Admiral template, which works in a way similar to docker compose, to deploy your WordPress application.  Simply go to _Templates_ and choose the icon of _Import template_ or _Docker Compose_. Then copy and paste the content of our _docker-compose.yml_ file into the text box. Click the Import button on the bottom right and then click _provision_ on the next page.  The wordpress application is ready for access after the status of the _Provision Request_ becomes _Finished_.

![Screenshot of Admiral Templates](https://blogs.vmware.com/vsphere/files/2017/02/admiral_alpine.png)
