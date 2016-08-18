Currently, the way to run Harbor is into a regular [Linux Docker host](setup-linux-docker-host.md)

### Preparing the Harbor installation

Setting up up Harbor is pretty straightforward. Harbor is comprised of a number of containers that are instantiated as a single application using docker-compose. 

We will instantiate Harbor on the Linux VM. 

Before you start deploying Harbor, make sure you don't have stale environment variables from previous experiments, such as DOCKER_HOST. Simplest way to do this is by running a new shell:

```
sudo bash
```

You want to make sure all Docker commands we are going to use (behind the scenes) work against the local Linux VM.

Note that the pre-requisites to install Harbor on the Linux VM are:
- Docker 1.11+
- docker-compose 1.8
- Python 2.7 (or later)

### Installation procedure for Harbor

On the Linux VM these are the steps to setup Harbor. Note that you will need a working internet connection in order to pull down the necessary harbor containers from DockerHub.

- Run `curl -L https://github.com/vmware/harbor/releases/download/0.3.5/harbor-installer.tgz > harbor-installer.tgz`
- Run `tar xvf harbor-installer.tgz`
- Move inside the `harbor` folder. 
- Edit the file `harbor.cfg` and change the following lines:
  - `hostname = 10.140.50.77` (the Docker host IP)
  - `harbor_admin_password = Vmware123!`
- Run `./install.sh`

This will kick off the install process which pulls the proper images from Docker Hub and instantiate them using `docker-compose`.  

After a few minutes you should see this:
```
root@lab-vic01:~/harbor/Deploy# docker ps
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                                      NAMES
eeec76ec8a16        library/nginx:1.9.0        "nginx -g 'daemon off"   2 hours ago         Up 2 hours          0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   harbor_proxy_1
d5f78f3469d1        vmware/harbor-jobservice   "/harbor/harbor_jobse"   2 hours ago         Up 2 hours                                                     harbor_jobservice_1
53a2dcac4bd1        vmware/harbor-ui           "/harbor/harbor_ui"      2 hours ago         Up 2 hours                                                     harbor_ui_1
bce8a89eaeb0        library/registry:2.5.0     "/entrypoint.sh serve"   2 hours ago         Up 2 hours          5000/tcp, 0.0.0.0:5001->5001/tcp           harbor_registry_1
425074aa06f6        vmware/harbor-db           "/entrypoint.sh mysql"   2 hours ago         Up 2 hours          3306/tcp                                   harbor_mysql_1
0dec0ce11235        vmware/harbor-log          "/bin/sh -c 'crond &&"   2 hours ago         Up 2 hours          0.0.0.0:1514->514/tcp                      harbor_log_1
```

***Please note: the first time you start the registry a new local directory (/data) is mapped inside the containers and it provides consistency across deployments. If you want to start from scratch (and lose everything) you need to delete the /data directory.*** 

If everything worked, you should point the browser to the Linux VM (in this case 10.140.50.77) on port 80 and see the Harbor portal. Port 80 is the port that the Harbor frontend component is exposed on.

Now you can login using _admin_ and the password you set in harbor.cfg (we used _Vmware123!_).

Among the many features Harbor provides, there is also RBAC support. 

The Admin has the capability to create additional users in the system. There is no support for groups at the moment. These users can be given Admin privileges or they can just be regular users.

All users have the capability to create Projects and the project owner (who created it) can provide access level to existing users to specific projects (unless the user creates a public project, at which point everyone can see it without requiring any login).   

For the purpose of our next [exercise](using-harbor.md) you will need to:

- create 2 users: jane and mark
- create a project called vmworld 
- give mark “developer” access to the vmworld project (you will not explicitly allow jane to access it) 

Mark will now be able to push / pull to the vmworld project. 

***Note that, at this point in time, projects and policies cannot be deleted.  A user can be deleted but a user with same username can not be added after the deletion. Plan carefully.***
