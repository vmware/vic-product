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

```
#!/bin/bash
docker-compose up –d
```

### Verify that the nodes are running:

http://<vch_ip>:4444/grid/console

### If you need more nodes, just scale it up:

```
docker-compose scale chrome=5
```

### If you need less, scale it down:

```
docker-compose scale chrome=1
```

### If you need to stop everyting and restart:

```
docker-compose stop
docker-compose rm
```

Check also the [Selenium Blog Article](https://blogs.vmware.com/cloudnative/2018/02/28/running-selenium-grid-vsphere-vsphere-integrated-containers/) on the VMware CNA Blog for a more detailed description.
