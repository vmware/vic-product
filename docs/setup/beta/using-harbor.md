(Please see [Installing Harbor](install-configure-harbor.md) for information on how to set up Harbor)

### Interacting with Harbor

So far we have only played with images that are hosted on the official Docker Hub.

While we have deployed the VCH to allow insecure connections to our Harbor instance and while we have already configured Admiral to point to that Harbor instance, we haven't actually yet taken advantage of our private registry yet.

#### Interacting with Harbor with a Docker Host

To start, we will use our client machine as a Docker host to show how to interact with a private registry.

First thing first, since we are not using signed certificates, we need to instruct the Docker daemon that it’s ok to connect to an a non trusted registry. This is similar to what we have done when [deploying VCH1](install-configure-vch.md) by adding the `--docker-insecure-registry` flag.

You do so by adding `--insecure-registry 10.140.50.77:80` to the DOCKER_OPTS file.

In your PhotonOS client machine you need to edit /etc/default/docker and add the following line:
```
DOCKER_OPTS="--insecure-registry 10.140.50.77:80"
```
Note that with Photon OS the file needs to be created (on other Linux distros it may already exist).

Then you need to restart the docker service. On Photon OS you can run `systemctl restart docker`.

Harbor’s [user guide](https://github.com/vmware/harbor/blob/master/docs/user_guide.md) has more detailed information on image management but this is, in a nutshell what you can do from the Linux VM.

First thing, we check what images we have available locally (remember to get rid of any stale DOCKER_HOST or DOCKER_API environment variables from other exercises first).

We have none as we are using a brand new client machine (note that the nginx image we instantiated against VCH1 in the [previous exercise](install-configure-vch.md) was pulled on VCH1 not on this Docker host):
```
root@photonOSvm1 [ ~ ]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```

Let's pull the `nginx:1.9.0` image from Docker hub onto this host:
```
root@photonOSvm1 [ ~ ]# docker pull nginx:1.9.0
1.9.0: Pulling from library/nginx
e5ad7970bc69: Pull complete
a3ed95caeb02: Pull complete
2767943aa23d: Pull complete
5a40bd63d577: Pull complete
90ba96f0c53d: Pull complete
d83ac9507937: Pull complete
1512e0f1740f: Pull complete
Digest: sha256:4157ed7179858886f21024583247a875bafd8e8966e1cf68b4c8916963b20b62
Status: Downloaded newer image for nginx:1.9.0
```

Let's check that the image has been pulled properly:
```
root@photonOSvm1 [ ~ ]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               1.9.0               7e156d496c9f        16 months ago       132.8 MB
```

Let’s try to push the nginx image we pulled from Docker hub into Harbor. Note we are logging in as user _mark_:
```
root@photonOSvm1 [ ~ ]# docker login 10.140.50.77:80
Username: mark
Password:
Login Succeeded
```

We are tagging _nginx:1.9.0_ to prepare for pushing it to Harbor:
```
root@photonOSvm1 [ ~ ]# docker tag nginx:1.9.0 10.140.50.77:80/vmworld/nginx:1.9.0
```
***Note that if we're using a version as part of the tag and push, the version needs to be hacked in manually when we deploy the image from Admiral - this won't happen automatically. It may be better to not add the version. Also note that it is important to specify port :80 during the tagging for Admiral to be able to reference the image properly.***

We are now pushing _nginx:1.9.0_ to Harbor in the _vmworld_ project (we can do that because mark has proper access to the vmworld project):
```
root@photonOSvm1 [ ~ ]# docker push 10.140.50.77:80/vmworld/nginx:1.9.0
The push refers to a repository [10.140.50.77:80/vmworld/nginx]
5f70bf18a086: Pushed
d24da286ea0a: Pushed
943b315a8e6d: Pushed
c7b72e82d306: Pushed
3a5d8b4d4af1: Pushed
b130b4720ff3: Pushed
c5cc83103be7: Pushed
1.9.0: digest: sha256:a904be9a4f971b5f1de33ac9a03a045f030c9f6e432dac384356ba6aaa2dc11a size: 2805
```

If you check the Harbor UI, in the vmworld project, you should now see a new item (i.e. _nginx:1.9.0_)

#### Interacting with Harbor with a Virtual Container Host (VCH)

Our VCH (VCH1) has alrady been deployed with the `--docker-insecure-registry 10.140.50.77` flag set in anticipation of being able to pull from our local Harbor registry when using VCH1.

As we hinted in the [VCH deployment section](install-configure-vch.md), in case you need to consume a Harbor instance that has self-signed certificates, then you need to set the `--docker-insecure-registry` at the VCH level.

As we have seen, you can just add `--docker-insecure-registry` to the `vic-machine` command you use to deploy the Virtual Container Host. This will tell the VCH that it's ok to pull from the Harbor registry hosted at 10.140.50.77. If you need to add more than one registry, just repeat the option for each IP.

Since we have already deployed VCH1 with that flag, we can interact with it to pull the _nginx:1.9.0_ image from Harbor (the image we just pushed). Note that now we are explicitly working with VCH1 (by virtue of the -H flag):
```
root@photonOSvm1 [ ~ ]# docker -H 10.140.51.101:2376 --tls pull 10.140.50.77:80/vmworld/nginx:1.9.0
Pulling from vmworld/nginx
a3ed95caeb02: Pull complete
e5ad7970bc69: Pull complete
2767943aa23d: Pull complete
5a40bd63d577: Pull complete
90ba96f0c53d: Pull complete
d83ac9507937: Pull complete
1512e0f1740f: Pull complete
Digest: sha256:39e2153fc1ad63dc419d02e2c38e12e5f7074ef60ec1acc48ff70b63d007a444
Status: Downloaded newer image for vmworld/nginx:1.9.0
```

As usual, if you set the `DOCKER_HOST` variable with `export DOCKER_HOST=tcp://10.140.51.101:2376` there would be no need to specify the `-H` option in the command above.

As a final check let's see the list of images that are currently available for our VCH (VCH1):
```
root@photonOSvm1 [ ~ ]# docker -H 10.140.51.101:2376 --tls images
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
nginx                        latest              f7df00cd0f62        9 days ago          181.3 MB
vmware/admiral               latest              538645599b3b        3 weeks ago         506.4 MB
busybox                      latest              332de81782ef        3 months ago        1.093 MB
10.140.50.77/vmworld/nginx   1.9.0               7e156d496c9f        16 months ago       132.8 MB
```

The first three images are those we pulled during our previous exercises. The fourth one (_10.140.50.77/vmworld/nginx_) is the image we have just pulled from our local Harbor instance.

```
root@photonOSvm1 [ ~ ]# docker -H 10.140.51.101:2376 --tls run -d -p 81:80 --name nginxfromharborimage 10.140.50.77/vmworld/nginx:1.9.0
73c4d46ba648597f880efafe2af96208804da72cb7f26a0fd63ae804f0261230
```

Note we had to NAT port 81 since port 80 was already used by the other nginx containerVM we deployed previously.

Now this is what I have running on VCH1:
```
root@photonOSvm1 [ ~ ]# docker -H 10.140.51.101:2376 --tls ps
CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS              PORTS               NAMES
73c4d46ba648        10.140.50.77/vmworld/nginx:1.9.0   "nginx -g daemon off;"   2 minutes ago       Running                                 nginxfromharborimage
a900c4435f00        nginx                              "nginx -g daemon off;"   About an hour ago   Running                                 mynginx
95fce528c0e4        vmware/admiral                     "/entrypoint.sh"         About an hour ago   Running                                 admiral
```
