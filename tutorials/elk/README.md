# Automating provisioning of Higly Available Elastic Stack cluster

This is a simple docker-compose file to provision a higly avaialbe Elastic Stack cluster with 3 Elastic Search Nodes, 2 Logstash Nodes and 2 Kibana Nodes.

### Set the COMPOSE_TLS_VERSION correctly
This is required as TLS 1.0 & 1.1 have been deprecated

```
  $ export COMPOSE_TLS_VERSION=TLSv1_2
```

### Point your docker client to the VCH
This command will configure the VCH as default Docker Endpoint. vch.corp.local is the FQDN of Virtual Container Host created in VIC. Replace this with your FQDN/IP of the Virtual Container Host. 
 
```
  $ export DOCKER_HOST=vch.corp.local:2376
```
 
 
### Spin up all the relevant containers
The following command will spin up Elastic Stack based on the configuration in the docker compose file. The command is run with '-d' option which tells docker-compose to run it in the detached mode, that is, run it in background. vSphere Integrated Contaienrs 1.4 supports Docker Compose file version 2, 2.1, and 2.2.
 
```
  $ docker-compose up -d
```


Check also the [Elastic Stack Blog Article](https://blogs.vmware.com/cloudnative/2018/07/19/getting-started-with-elastic-stack-on-vsphere-integrated-containers/) on the VMware CNA Blog for a more detailed description. This blog Article covers, in detail, the pre-reqs as well as the steps required to run ELK in VIC.
