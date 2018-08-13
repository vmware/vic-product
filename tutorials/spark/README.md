# Automating Apache Spark with vSphere Integrated Containers

The docker-compose file covers bringing up a Apache Spark cluster with 1 Master and 1 Worker node. Furthermore, the container is modified to scale dynamically to add/remove worker nodes from the Spark cluster.
The Master and Worker containers are build on top of work done by https://hub.docker.com/r/p7hb/docker-spark/.

### Set the COMPOSE_TLS_VERSION correctly

It is very important to set the `COMPOSE_TLS_VERSION` correctly (e.g in `$HOME/.bashrc` ot `$HOME/.bash_profile`) as TLS 1.0 & 1.1 have been deprecated

```
export COMPOSE_TLS_VERSION=TLSv1_2
```

### Point your docker client to the VCH

```
export DOCKER_HOST=<VCH_IP:port>

e.g export DOCKER_HOST=vch.corp.local:2376
```


### Start the Master and Worker Nodes:
Download the docker-compose.yml file and make sure the it is in the same directory from where you are running the docker-compose up -d command

```
docker-compose up –d
```

### Verify that the nodes are running:

```
http://<vch_fqdn>:8080
```

### If you need more Worker Nodes, just scale it up:

```
docker-compose up --scale worker=5 -d
```

### If you need less, scale it down:

```
docker-compose down --scale worker=1 -d
```

### If you need to stop everyting and restart:

```
docker-compose stop
docker-compose rm
```

Check also the [Apache Spark Blog Article](https://blogs.vmware.com/cloudnative/2018/08/08/fire-up-your-data-processing-with-apache-spark-on-vsphere-integrated-containers/) on the VMware CNA Blog for a more detailed description.
