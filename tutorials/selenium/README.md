# Automating Selenium Grid with vSphere Integrated Containers

This is a simple [docker-compose](https://docs.docker.com/compose/) file that deploys a sample grid with one hub and one chrome and firefox node. 


### Set the COMPOSE_TLS_VERSION correctly

It is very important to set the `COMPOSE_TLS_VERSION` correctly (e.g in `$HOME/.bashrc` ot `$HOME/.bash_profile`), otherwise you will get an error.

```
export COMPOSE_TLS_VERSION=TLSv1_2
```

### Point your docker client to the VCH

```
export DOCKER_HOST=<VCH_IP:port>

e.g export DOCKER_HOST=10.158.204.227:2375
```


### Start the hub and chrome/firefox nodes:
Download the docker-compose.yml file and make sure the it is in the same directory from where you are running the docker-compose up -d command

```
#!/bin/bash
docker-compose up –d
```

### Verify that the nodes are running:

http://<vch_ip>:4444/grid/console

### If you need more nodes, just scale it up:

```
docker-compose up --scale chrome=5 -d
```

### If you need less, scale it down:

```
docker-compose down --scale chrome=1 -d
```

### If you need to stop everyting and restart:

```
docker-compose stop
docker-compose rm
```

Check also the [Selenium Blog Article](https://blogs.vmware.com/cloudnative/2018/03/07/running-selenium-grid-vsphere-integrated-containers/) on the VMware CNA Blog for a more detailed description.
