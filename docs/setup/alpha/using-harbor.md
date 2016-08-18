(Please see [Installing Harbor](install-configure-harbor.md) for information on how to set up Harbor)

### Interacting with Harbor

We will use our Linux VM as a Docker host to show how to interact with a private registry. 

First thing first, since we are not using signed certificates, we need to instruct the Docker daemon that it’s ok to connect to an a non trusted registry. 

You do so by adding `--insecure-registry 10.140.50.77` to DOCKER_OPTS. 

Note: we are adding the Linux VM ip address because that is where Harbor is running. We are, incidentally and conveniently, using the same linux host to connect to the registry. 

In your Linux VM you need to edit /etc/default/docker and add the following line:
```
DOCKER_OPTS="--insecure-registry 10.140.50.77"
```
Note that in Ubuntu the file already exists whereas in Photon OS it needs to be created. 

Then you need to restart the docker service. On Ubuntu you can run `service docker restart` whereas on Photon OS you can run `systemctl restart docker`. 

Harbor’s [user guide](https://github.com/vmware/harbor/blob/master/docs/user_guide.md) has more detailed information on image management but this is, in a nutshell what you can do from the Linux VM. 

First thing, we check what images we have available locally (remember to get rid of any stale DOCKER_HOST or DOCKER_API environment variables from other exercises first). 
Some of them had been pulled from Docker hub, some others we built them locally (the Harbor images):
```
root@lab-vic01:~/harbor/Deploy# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
deploy_jobservice   latest              9f1ae108d31c        24 minutes ago      786.4 MB
deploy_mysql        latest              7d9e4bc4e1f6        24 minutes ago      328.9 MB
deploy_ui           latest              c8466d42c317        24 minutes ago      809 MB
deploy_log          latest              9698e37f36ba        25 minutes ago      188 MB
ubuntu              14.04               ff6011336327        4 days ago          188 MB
mysql               5.6                 5e0f1b09e25e        2 weeks ago         328.9 MB
golang              1.6.2               8ecba0e9bd48        6 weeks ago         753.6 MB
nginx               1.9                 c8c29d842c09        12 weeks ago        182.8 MB
registry            2.4.0               8b162eee2794        3 months ago        171.2 MB
```

Let’s try to push the nginx image we pulled from Docker hub into Harbor. Note we are logging in as user _mark_:
```
root@lab-vic01:~/harbor/Deploy# docker login 10.140.50.77 
Username: mark
Password: 
Login Succeeded
```

We are tagging nginx:1.9 to prepare for pushing it to Harbor:
```
root@lab-vic01:~/harbor/Deploy# docker tag nginx:1.9.0 10.140.50.77/vmworld/nginx:1.9.0
```
[FIXME: Note that if we're using a version as part of the tag and push, the version needs to be hacked in manually when we deploy the image from Admiral - this won't happen automatically. It may be better to not add the version]

We are now pushing nginx:1.9 to Harbor in the _vmworld_ project (we can do that because mark has proper access to the vmworld project):
```
root@lab-vic01:~/harbor/Deploy# docker push 10.140.50.77/vmworld/nginx:1.9.0
The push refers to a repository [10.140.50.77/vmworld/nginx]
5f70bf18a086: Pushed 
49027b789c92: Pushed 
20f8e7504ae5: Pushed 
4dcab49015d4: Pushed 
1.9: digest: sha256:311e9840c68d889e74eefa18227d0a6f995bc7a74f5453fdcd49fe3c334feb24 size: 1978
```

If you check the Harbor UI, in the vmworld project, you should now see a new item (i.e. nginx:1.9)
